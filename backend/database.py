from __future__ import annotations

import json
from contextlib import asynccontextmanager

import aiosqlite

DB_PATH = "/workspace/void-deck/backend/tarot.db"


async def create_tables() -> None:
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""CREATE TABLE IF NOT EXISTS tarot_cards (
            id TEXT PRIMARY KEY, name_en TEXT, name_zh TEXT, arcana TEXT,
            suit TEXT, number INTEGER, upright_meaning TEXT, reversed_meaning TEXT,
            love_meaning TEXT, career_meaning TEXT, finance_meaning TEXT,
            spiritual_meaning TEXT, advice TEXT, warning TEXT,
            keywords_upright TEXT, keywords_reversed TEXT, description TEXT)""")
        await db.execute("""CREATE TABLE IF NOT EXISTS spreads (
            id TEXT PRIMARY KEY, name TEXT, name_zh TEXT, description TEXT,
            card_count INTEGER, positions TEXT)""")
        await db.execute("""CREATE TABLE IF NOT EXISTS readings (
            id TEXT PRIMARY KEY, question TEXT, spread_id TEXT,
            selected_cards TEXT, ai_interpretation TEXT,
            created_at TEXT, updated_at TEXT)""")
        await db.execute("""CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT, reading_id TEXT,
            role TEXT CHECK(role IN ('user','assistant')),
            content TEXT, created_at TEXT)""")
        await db.commit()


async def seed_database() -> None:
    from .seed_data import SEED_CARDS
    async with aiosqlite.connect(DB_PATH) as db:
        for card in SEED_CARDS.values():
            await db.execute(
                """INSERT OR IGNORE INTO tarot_cards VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (card["id"], card["name_en"], card["name_zh"], card["arcana"],
                 card["suit"], card["number"], card["upright_meaning"], card["reversed_meaning"],
                 card["love_meaning"], card["career_meaning"], card["finance_meaning"],
                 card["spiritual_meaning"], card["advice"], card["warning"],
                 card["keywords_upright"], card["keywords_reversed"], card["description"]))
        await db.execute(
            """INSERT OR IGNORE INTO spreads VALUES (?,?,?,?,?,?)""",
            ("past_present_future", "Past-Present-Future", "過去現在未來",
             "A classic three-card spread: past, present, future.", 3,
             json.dumps([{"position":0,"name":"Past","name_zh":"過去","description":"Past influences"},
                        {"position":1,"name":"Present","name_zh":"現在","description":"Current situation"},
                        {"position":2,"name":"Future","name_zh":"未來","description":"Future direction"}])))
        await db.commit()


@asynccontextmanager
async def get_db():
    db = await aiosqlite.connect(DB_PATH)
    db.row_factory = aiosqlite.Row
    try: yield db
    finally: await db.close()
