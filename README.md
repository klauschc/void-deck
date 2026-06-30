# Void Deck — Tarot AI iOS App

A premium iOS Tarot AI reading app with manual card selection, open-ended follow-up chat, Liquid Glass purple UI, and DeepSeek V4 Pro powered interpretations.

## Architecture
- **iOS Frontend**: SwiftUI + MVVM + Liquid Glass (iOS 26+)
- **Backend**: FastAPI + SQLite + RAG prompt system
- **AI**: LLM API (OpenAI-compatible endpoint)
- **CI/CD**: GitHub Actions → unsigned IPA

## Backend Setup
```bash
cd backend
uv venv .venv
uv pip install -r requirements.txt
LLM_BASE_URL="..." LLM_API_KEY=*** .venv/bin/uvicorn backend.main:app
```

## API Endpoints
- `POST /api/readings` — Create tarot reading with AI interpretation
- `POST /api/readings/{id}/messages` — Send follow-up
- `GET /api/readings` — Reading history
- `GET /api/readings/{id}` — Full reading detail
- `GET /api/spreads` — Available spreads
- `GET /api/cards` — All 78 tarot cards
- `GET /api/cards/{id}` — Single card detail
