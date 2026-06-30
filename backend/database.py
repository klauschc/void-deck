from __future__ import annotations
import os

import json
from contextlib import asynccontextmanager

import aiosqlite

DB_PATH = os.path.join(os.path.dirname(__file__), "tarot.db")


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
        await db.execute("""INSERT OR IGNORE INTO spreads VALUES (?,?,?,?,?,?)""",
            ("past_present_future", "Past-Present-Future", "過去現在未來",
             "經典三張牌牌陣：過去、現在、未來。", 3,
             json.dumps([{"position_index":1,"name":"Past","name_zh":"過去","description":"過往背景、已發生的影響、問題根源"},
                        {"position_index":2,"name":"Present","name_zh":"現在","description":"當前狀態、核心能量、正在面對的情況"},
                        {"position_index":3,"name":"Future","name_zh":"未來","description":"可能發展、提醒、建議方向"}])))
        await db.execute("""INSERT OR IGNORE INTO spreads VALUES (?,?,?,?,?,?)""",
            ("celtic_cross", "Celtic Cross", "塞爾特十字",
             "經典十張牌牌陣，全面深入探討問題各層面。", 10,
             json.dumps([{"position_index":1,"name":"Present","name_zh":"現狀","description":"當前問題的核心"},
                        {"position_index":2,"name":"Challenge","name_zh":"阻礙","description":"面前的挑戰或障礙"},
                        {"position_index":3,"name":"Past","name_zh":"過去","description":"過往的影響"},
                        {"position_index":4,"name":"Future","name_zh":"未來","description":"即將到來的發展"},
                        {"position_index":5,"name":"Above","name_zh":"上方","description":"你的目標或理想"},
                        {"position_index":6,"name":"Below","name_zh":"下方","description":"潛意識或基礎"},
                        {"position_index":7,"name":"Advice","name_zh":"建議","description":"你應該採取的態度"},
                        {"position_index":8,"name":"Environment","name_zh":"環境","description":"外界影響或他人"},
                        {"position_index":9,"name":"Hopes/Fears","name_zh":"希望與恐懼","description":"內心期望或擔憂"},
                        {"position_index":10,"name":"Outcome","name_zh":"結果","description":"最終可能結果"}])))
        await db.execute("""INSERT OR IGNORE INTO spreads VALUES (?,?,?,?,?,?)""",
            ("relationship", "Relationship", "關係牌陣",
             "專為感情關係設計的五張牌牌陣。", 5,
             json.dumps([{"position_index":1,"name":"Me","name_zh":"我","description":"你在這段關係中的狀態"},
                        {"position_index":2,"name":"Them","name_zh":"對方","description":"對方的狀態或感受"},
                        {"position_index":3,"name":"Connection","name_zh":"連結","description":"你們之間的連結"},
                        {"position_index":4,"name":"Challenge","name_zh":"挑戰","description":"關係中的挑戰"},
                        {"position_index":5,"name":"Potential","name_zh":"潛力","description":"關係的可能發展"}])))
        await db.commit()


@asynccontextmanager
async def get_db():
    db = await aiosqlite.connect(DB_PATH)
    db.row_factory = aiosqlite.Row
    try: yield db
    finally: await db.close()
