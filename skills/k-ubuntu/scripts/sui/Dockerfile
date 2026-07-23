# --- Build Stage ---
FROM python:3.12-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# --- Runtime Stage ---
FROM python:3.12-slim
WORKDIR /app

# Non-root user for security
RUN useradd -m suiuser
USER suiuser

ENV PATH="/app/.venv/bin:$PATH"
COPY --from=builder /app/.venv /app/.venv
COPY . .

ENTRYPOINT ["sui"]
