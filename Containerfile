# Production image for Locomotive. Local development runs natively (see README).
#
#   just image          build the image
#   just container-run  run it locally on http://127.0.0.1:8080

# --- Build stage: install dependencies and collect static files ---
FROM docker.io/library/python:3.14-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0

WORKDIR /app

# Dependencies first, so this layer is cached until uv.lock changes.
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev --no-install-project

COPY src ./src

# collectstatic only needs *a* secret key to load settings; the real one is
# provided at runtime.
RUN echo build-only > /tmp/secret_key \
    && DJANGO_SECRET_KEY_FILE=/tmp/secret_key \
       /app/.venv/bin/python src/manage.py collectstatic --noinput

# --- Runtime stage: no uv, no build cache, unprivileged user ---
FROM docker.io/library/python:3.14-slim

RUN useradd --system --create-home --uid 1000 app \
    && mkdir /data \
    && chown app:app /data

COPY --from=builder --chown=app:app /app /app

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    DJANGO_DEBUG=false \
    DJANGO_DB_PATH=/data/db.sqlite3 \
    DJANGO_SECRET_KEY_FILE=/run/secrets/django_secret_key

USER app
WORKDIR /app/src
EXPOSE 8000

# Apply migrations, then hand over to gunicorn. Mount a volume on /data to
# keep the database, and provide the secret key at DJANGO_SECRET_KEY_FILE.
CMD ["sh", "-c", "python manage.py migrate --noinput && exec gunicorn locomotive.wsgi --bind 0.0.0.0:8000 --workers 3 --access-logfile -"]
