"""FastAPI Tarot AI backend."""
from __future__ import annotations

import os as _os
from dotenv import load_dotenv
for _p in ['/app/.env', '/workspace/void-deck/.env', '.env']:
    if _os.path.exists(_p): load_dotenv(_p); break

import json
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .database import create_tables, get_db, seed_database
from .prompts import SYSTEM_PROMPT_FIRST, SYSTEM_PROMPT_FOLLOWUP, build_first_reading_prompt, build_followup_prompt
from .llm_client import chat_completion
from .seed_data import SEED_CARDS
from .models import FollowUpRequest, MessageCreate, ReadingCreate


@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_tables()
    await seed_database()
    yield


app = FastAPI(title="Tarot AI API", version="0.1.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/spreads")
async def list_spreads():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM spreads")
        rows = await cursor.fetchall()
        results = []
        for row in rows:
            d = dict(row)
            d["positions"] = json.loads(d["positions"])
            results.append(d)
        return results


@app.get("/api/cards")
async def list_cards():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM tarot_cards ORDER BY arcana, suit, number")
        rows = await cursor.fetchall()
        return [dict(r) for r in rows]


@app.get("/api/cards/{card_id}")
async def get_card(card_id: str):
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM tarot_cards WHERE id = ?", (card_id,))
        row = await cursor.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Card not found")
        return dict(row)


@app.post("/api/readings")
async def create_reading(body: ReadingCreate):
    reading_id = str(uuid4())
    now = datetime.now(timezone.utc).isoformat()
    async with get_db() as db:
        await db.execute(
            """INSERT INTO readings (id, question, spread_id, selected_cards, ai_interpretation, created_at, updated_at)
               VALUES (?, ?, ?, ?, NULL, ?, ?)""",
            (reading_id, body.question, body.spread_id, json.dumps(body.cards), now, now),
        )
        await db.commit()

    # Build reading context for AI
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM spreads WHERE id = ?", (body.spread_id,))
        spread_row = await cursor.fetchone()
        if not spread_row:
            raise HTTPException(status_code=404, detail="Spread not found")
        spread = dict(spread_row)
        spread["positions"] = json.loads(spread["positions"])

    cards_info = []
    card_meanings_parts = []
    for c in body.cards:
        card_id = c["card_id"]
        card_data = SEED_CARDS.get(card_id, {})
        pos = next((p for p in spread["positions"] if p.get("position_index", p.get("position")) == c.get("position_index", c.get("position", 0))), {})
        orientation = c.get("orientation", "upright")
        cards_info.append({"position_name": pos.get("name", pos.get("name_zh", "")), "card_name_zh": card_data.get("name_zh", card_id), "orientation": orientation})
        meaning_key = "upright_meaning" if orientation == "upright" else "reversed_meaning"
        card_meanings_parts.append(f"【{card_data.get('name_zh', card_id)}-{'正位' if orientation == 'upright' else '逆位'}】\n{card_data.get(meaning_key, '')}\n感情：{card_data.get('love_meaning', '')}")

    positions_text = chr(10).join(f"{p.get('position_index', p.get('position', i+1))}. {p.get('name', p.get('name_zh', ''))}：{p.get('description', '')}" for i, p in enumerate(spread["positions"]))

    try:
        user_prompt = build_first_reading_prompt(body.question, spread["name"], positions_text, cards_info, chr(10).join(card_meanings_parts))
        api_key = getattr(body, 'api_key', None)
        interpretation = await chat_completion(SYSTEM_PROMPT_FIRST, user_prompt, api_key=api_key)
    except Exception as e:
        interpretation = f"[AI 解讀暫時無法生成：{str(e)}]"

    async with get_db() as db:
        await db.execute("UPDATE readings SET ai_interpretation = ?, updated_at = ? WHERE id = ?", (interpretation, datetime.now(timezone.utc).isoformat(), reading_id))
        await db.commit()

    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings WHERE id = ?", (reading_id,))
        row = await cursor.fetchone()
        d = dict(row)
        d["selected_cards"] = json.loads(d["selected_cards"])
        return d


@app.get("/api/readings")
async def list_readings():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings ORDER BY created_at DESC")
        rows = await cursor.fetchall()
        results = []
        for r in rows:
            d = dict(r)
            d["selected_cards"] = json.loads(d["selected_cards"])
            results.append(d)
        return results


@app.get("/api/readings/{reading_id}")
async def get_reading(reading_id: str):
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings WHERE id = ?", (reading_id,))
        row = await cursor.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Reading not found")
        reading = dict(row)
        reading["selected_cards"] = json.loads(reading["selected_cards"])

        cursor = await db.execute(
            "SELECT * FROM messages WHERE reading_id = ? ORDER BY created_at ASC",
            (reading_id,),
        )
        msg_rows = await cursor.fetchall()
        reading["messages"] = [dict(m) for m in msg_rows]
        return reading


@app.post("/api/readings/{reading_id}/messages")
async def add_message(reading_id: str, body: MessageCreate):
    now = datetime.now(timezone.utc).isoformat()
    async with get_db() as db:
        cursor = await db.execute("SELECT id FROM readings WHERE id = ?", (reading_id,))
        if await cursor.fetchone() is None:
            raise HTTPException(status_code=404, detail="Reading not found")
        await db.execute(
            "INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)",
            (reading_id, body.role, body.content, now),
        )
        await db.execute(
            "UPDATE readings SET updated_at = ? WHERE id = ?",
            (now, reading_id),
        )
        await db.commit()
        return {"status": "ok"}


@app.post("/api/readings/{reading_id}/follow-up")
async def follow_up(reading_id: str, body: FollowUpRequest):
    now = datetime.now(timezone.utc).isoformat()

    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings WHERE id = ?", (reading_id,))
        row = await cursor.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Reading not found")
        reading = dict(row)
        reading["selected_cards"] = json.loads(reading["selected_cards"])

        cursor = await db.execute("SELECT * FROM spreads WHERE id = ?", (reading["spread_id"],))
        spread_row = await cursor.fetchone()
        spread = dict(spread_row)
        spread["positions"] = json.loads(spread["positions"])

        # Get chat history
        cursor = await db.execute(
            "SELECT * FROM messages WHERE reading_id = ? ORDER BY created_at ASC",
            (reading_id,),
        )
        msg_rows = await cursor.fetchall()
        messages = [dict(m) for m in msg_rows]

    # Collect card meanings
    cards_info = []
    card_meanings_parts = []
    for c in reading["selected_cards"]:
        card_id = c.get("card_id", "")
        card_data = SEED_CARDS.get(card_id, {})
        pos = next((p for p in spread["positions"] if p.get("position_index", p.get("position")) == c.get("position_index", c.get("position", 0))), {})
        orientation = c.get("orientation", "upright")
        cards_info.append({
            "position_name": pos.get("name", pos.get("name_zh", "")),
            "card_name_zh": card_data.get("name_zh", card_id),
            "orientation": orientation,
        })
        meaning_key = "upright_meaning" if orientation == "upright" else "reversed_meaning"
        card_meanings_parts.append(
            f"【{card_data.get('name_zh', card_id)}-{'正位' if orientation == 'upright' else '逆位'}】"
            f"\n{card_data.get(meaning_key, '')}"
            f"\n感情：{card_data.get('love_meaning', '')}"
        )

    # Build positions text
    positions_text = chr(10).join(
        f"{p.get('position_index', p.get('position', i+1))}. {p.get('name', p.get('name_zh', ''))}：{p.get('description', '')}"
        for i, p in enumerate(spread["positions"])
    )

    # Build chat history text
    chat_history = chr(10).join(
        f"[{m['role']}]: {m['content']}" for m in messages
    ) or "(尚無對話記錄)"

    # Save user message
    async with get_db() as db:
        await db.execute(
            "INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)",
            (reading_id, "user", body.message, now),
        )

    # Generate AI reply
    try:
        user_prompt = build_followup_prompt(
            reading["question"],
            spread["name"],
            positions_text,
            cards_info,
            reading.get("ai_interpretation", ""),
            chat_history,
            body.message,
            chr(10).join(card_meanings_parts),
        )
        reply = await chat_completion(SYSTEM_PROMPT_FOLLOWUP, user_prompt)
    except Exception as e:
        reply = f"[AI 回覆暫時無法生成：{str(e)}]"

    # Save AI reply
    async with get_db() as db:
        await db.execute(
            "INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)",
            (reading_id, "assistant", reply, datetime.now(timezone.utc).isoformat()),
        )
        await db.execute(
            "UPDATE readings SET ai_interpretation = ?, updated_at = ? WHERE id = ?",
            (reply, datetime.now(timezone.utc).isoformat(), reading_id),
        )
        await db.commit()

    return {"reading_id": reading_id, "message": body.message, "response": reply}
