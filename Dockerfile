# Use official Python image
FROM python:3.11-slim

# Set environment variables
ENV POETRY_VERSION=1.7.1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install curl and dependencies for poetry
RUN apt-get update && apt-get install -y curl build-essential

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy only pyproject files first to install deps
COPY pyproject.toml poetry.lock* /app/

# Install dependencies without dev
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi --only main

# Copy your actual codebase
COPY . /app

# Expose FastAPI port
EXPOSE 8000

# Launch FastAPI with Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
FROM python:3.11-slim

ENV POETRY_VERSION=1.7.1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies required by psycopg (v3) and Poetry
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

# Copy dependency definitions
COPY pyproject.toml poetry.lock* /app/

# Install project dependencies (no venv)
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi --only main

# Copy application code
COPY . /app

EXPOSE 8000

# Start FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

