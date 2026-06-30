"""Async LLM client - OpenAI-compatible API."""
from __future__ import annotations

import os
from typing import Any

import httpx

LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://integrate.api.nvidia.com/v1")
LLM_API_KEY=*** "")
LLM_MODEL = os.getenv("LLM_MODEL", "deepseek-ai/deepseek-v4-pro")
LLM_MAX_TOKENS=*** "4096"))
LLM_TEMPERATURE = float(os.getenv("LLM_TEMPERATURE", "0.7"))


async def chat_completion(system_prompt, user_prompt, *, model=None, max_tokens=None, temperature=None):
    if not LLM_API_KEY:
        raise RuntimeError("LLM_API_KEY env var not set")
    payload = {
        "model": model or LLM_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "max_tokens": max_tokens or LLM_MAX_TOKENS,
        "temperature": temperature or LLM_TEMPERATURE,
    }
    headers = {
        "Authorization": f"Bearer {LLM_API_KEY}",
        "Content-Type": "application/json",
    }
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(f"{LLM_BASE_URL}/chat/completions", json=payload, headers=headers)
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]
