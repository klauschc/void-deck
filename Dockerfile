FROM python:3.13-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt python-dotenv
COPY backend/ ./backend/
ENV LLM_BASE_URL=https://integrate.api.nvidia.com/v1
ENV LLM_MODEL=minimaxai/minimax-m3
ENV LLM_MAX_TOKENS=***
ENV LLM_TEMPERATURE=0.7
EXPOSE 8000
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
