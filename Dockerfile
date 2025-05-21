# --- Stage 1: Lint ---
FROM python:3.9-slim AS linter

WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir flake8

COPY src/ src/
RUN flake8 src

# --- Stage 2: Build ---
FROM python:3.9-slim AS builder

WORKDIR /app
RUN apt-get update && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ src/

# --- Stage 3: Test ---
FROM builder AS tester

WORKDIR /app
RUN pip install --no-cache-dir pytest

COPY tests/ tests/
RUN pytest --maxfail=1 --disable-warnings -q

# --- Stage 4: Runtime ---
FROM python:3.9-slim AS runtime

WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY src/ src/

EXPOSE 8080
ENV FLASK_APP=src/app.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]