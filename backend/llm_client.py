"""Async LLM client - OpenAI-compatible API."""
from __future__ import annotations

import os
from typing import Any

import httpx

LLM_BASE_URL = os.getenv("LLM_BASE_URL", "https://integrate.api.nvidia.com/v1")
_key = os.getenv("LLM_API_KEY", "") or os.getenv("NVIDIA_BUILD_API_KEY", "")
LLM_API_KEY = _key
LLM_MODEL = os.getenv("LLM_MODEL", "minimaxai/minimax-m3")
LLM_MAX_TOKENS = int(os.getenv("LLM_MAX_TOKENS", "4096"))
LLM_TEMPERATURE = float(os.getenv("LLM_TEMPERATURE", "0.7"))


async def chat_completion(system_prompt, user_prompt, *, model=None, max_tokens=None, temperature=None, api_key=None):
    key = api_key or LLM_API_KEY
    if not key:
        raise RuntimeError("No API key provided. Set LLM_API_KEY or pass api_key.")
    base = LLM_BASE_URL.rstrip("/")
    url = base if base.endswith("/chat/completions") else f"{base}/chat/completions"
    payload = {"model": model or LLM_MODEL, "messages": [{"role": "system", "content": system_prompt}, {"role": "user", "content": user_prompt}], "max_tokens": max_tokens or LLM_MAX_TOKENS, "temperature": temperature or LLM_TEMPERATURE}
    headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(url, json=payload, headers=headers)
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]
