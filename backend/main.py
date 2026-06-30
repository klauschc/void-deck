from __future__ import annotations

import json
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from uuid import uuid4

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .database import create_tables, get_db, seed_database
from .models import FollowUpRequest, MessageCreate, ReadingCreate
from .prompts import SYSTEM_PROMPT_FIRST, SYSTEM_PROMPT_FOLLOWUP, build_first_reading_prompt, build_followup_prompt
from .llm_client import chat_completion
from .seed_data import SEED_CARDS


@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_tables()
    await seed_database()
    yield


app = FastAPI(title="Tarot AI API", version="0.1.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])


@app.get("/api/spreads")
async def list_spreads():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM spreads")
        rows = await cursor.fetchall()
        return [dict(r) | {"positions": json.loads(dict(r)["positions"])} for r in rows]


@app.get("/api/cards")
async def list_cards():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM tarot_cards ORDER BY arcana, suit, number")
        return [dict(r) for r in await cursor.fetchall()]


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
    cards_json = json.dumps([{"position_index": c.get("position_index", c.get("position", 0)), "card_id": c["card_id"], "orientation": c["orientation"]} for c in body.cards])
    
    async with get_db() as db:
        await db.execute("INSERT INTO readings (id, question, spread_id, selected_cards, ai_interpretation, created_at, updated_at) VALUES (?, ?, ?, ?, NULL, ?, ?)", (reading_id, body.question, body.spread_id, cards_json, now, now))
        await db.commit()
    
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
        card_meanings_parts.append(f"【{card_data.get('name_zh', card_id)}-{'正位' if orientation == 'upright' else '逆位'}】\n{card_data.get(meaning_key, '')}\n感情：{card_data.get('love_meaning', '')}\n事業：{card_data.get('career_meaning', '')}\n建議：{card_data.get('advice', '')}")
    
    positions_text = chr(10).join(f"{p.get('position_index', p.get('position', i+1))}. {p.get('name', p.get('name_zh', ''))}：{p.get('description', '')}" for i, p in enumerate(spread["positions"]))
    
    try:
        user_prompt = build_first_reading_prompt(body.question, spread["name"], positions_text, cards_info, chr(10).join(card_meanings_parts))
        interpretation = await chat_completion(SYSTEM_PROMPT_FIRST, user_prompt)
    except Exception as e:
        interpretation = f"[AI 解讀暫時無法生成：{str(e)}]"
    
    async with get_db() as db:
        await db.execute("UPDATE readings SET ai_interpretation = ?, updated_at = ? WHERE id = ?", (interpretation, datetime.now(timezone.utc).isoformat(), reading_id))
        await db.commit()
    
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings WHERE id = ?", (reading_id,))
        d = dict(await cursor.fetchone())
        d["selected_cards"] = json.loads(d["selected_cards"])
        return d


@app.get("/api/readings")
async def list_readings():
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings ORDER BY created_at DESC")
        return [dict(r) | {"selected_cards": json.loads(dict(r)["selected_cards"])} for r in await cursor.fetchall()]


@app.get("/api/readings/{reading_id}")
async def get_reading(reading_id: str):
    async with get_db() as db:
        cursor = await db.execute("SELECT * FROM readings WHERE id = ?", (reading_id,))
        row = await cursor.fetchone()
        if row is None:
            raise HTTPException(status_code=404, detail="Reading not found")
        reading = dict(row)
        reading["selected_cards"] = json.loads(reading["selected_cards"])
        cursor = await db.execute("SELECT * FROM messages WHERE reading_id = ? ORDER BY created_at ASC", (reading_id,))
        reading["messages"] = [dict(m) for m in await cursor.fetchall()]
        return reading


@app.post("/api/readings/{reading_id}/messages")
async def add_message(reading_id: str, body: MessageCreate):
    now = datetime.now(timezone.utc).isoformat()
    async with get_db() as db:
        cursor = await db.execute("SELECT id FROM readings WHERE id = ?", (reading_id,))
        if await cursor.fetchone() is None:
            raise HTTPException(status_code=404, detail="Reading not found")
        await db.execute("INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)", (reading_id, body.role, body.content, now))
        await db.execute("UPDATE readings SET updated_at = ? WHERE id = ?", (now, reading_id))
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
        spread = dict(await cursor.fetchone())
        spread["positions"] = json.loads(spread["positions"])
        cursor = await db.execute("SELECT * FROM messages WHERE reading_id = ? ORDER BY created_at ASC", (reading_id,))
        messages = [dict(m) for m in await cursor.fetchall()]
    
    cards_info = []
    card_meanings_parts = []
    for c in reading["selected_cards"]:
        card_id = c.get("card_id", "")
        card_data = SEED_CARDS.get(card_id, {})
        pos = next((p for p in spread["positions"] if p.get("position_index", p.get("position")) == c.get("position_index", c.get("position", 0))), {})
        orientation = c.get("orientation", "upright")
        cards_info.append({"position_name": pos.get("name", pos.get("name_zh", "")), "card_name_zh": card_data.get("name_zh", card_id), "orientation": orientation})
        meaning_key = "upright_meaning" if orientation == "upright" else "reversed_meaning"
        card_meanings_parts.append(f"【{card_data.get('name_zh', card_id)}-{'正位' if orientation == 'upright' else '逆位'}】\n{card_data.get(meaning_key, '')}")
    
    positions_text = chr(10).join(f"{p.get('position_index', p.get('position', i+1))}. {p.get('name', p.get('name_zh', ''))}：{p.get('description', '')}" for i, p in enumerate(spread["positions"]))
    chat_history = chr(10).join(f"[{m['role']}]: {m['content']}" for m in messages) or "(尚無對話記錄)"
    
    async with get_db() as db:
        await db.execute("INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)", (reading_id, "user", body.message, now))
    
    try:
        user_prompt = build_followup_prompt(reading["question"], spread["name"], positions_text, cards_info, reading.get("ai_interpretation", ""), chat_history, body.message, chr(10).join(card_meanings_parts))
        reply = await chat_completion(SYSTEM_PROMPT_FOLLOWUP, user_prompt)
    except Exception as e:
        reply = f"[AI 回覆暫時無法生成：{str(e)}]"
    
    async with get_db() as db:
        await db.execute("INSERT INTO messages (reading_id, role, content, created_at) VALUES (?, ?, ?, ?)", (reading_id, "assistant", reply, datetime.now(timezone.utc).isoformat()))
        await db.execute("UPDATE readings SET updated_at = ? WHERE id = ?", (datetime.now(timezone.utc).isoformat(), reading_id))
        await db.commit()
    return {"reading_id": reading_id, "message": body.message, "response": reply}
