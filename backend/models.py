"""Pydantic models for Tarot AI API."""
from __future__ import annotations

from typing import Literal

from pydantic import BaseModel


class TarotCard(BaseModel):
    id: str = ""
    name_en: str = ""
    name_zh: str = ""
    arcana: str = ""
    suit: str = ""
    number: int = 0
    upright_meaning: str = ""
    reversed_meaning: str = ""
    love_meaning: str = ""
    career_meaning: str = ""
    finance_meaning: str = ""
    spiritual_meaning: str = ""
    advice: str = ""
    warning: str = ""
    keywords_upright: str = ""
    keywords_reversed: str = ""
    description: str = ""


class Spread(BaseModel):
    id: str
    name: str
    name_zh: str
    description: str
    card_count: int
    positions: list[dict]


class Reading(BaseModel):
    id: str
    question: str
    spread_id: str
    selected_cards: list[dict]
    ai_interpretation: str | None = None
    created_at: str = ""
    updated_at: str = ""


class ReadingCreate(BaseModel):
    question: str
    spread_id: str
    cards: list[dict]


class MessageCreate(BaseModel):
    role: Literal["user", "assistant"]
    content: str


class FollowUpRequest(BaseModel):
    message: str
