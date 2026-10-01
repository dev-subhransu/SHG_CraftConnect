# Production Dockerfile for Google Cloud Run
# Uses official lightweight Python slim image
FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    HOST=0.0.0.0

WORKDIR /app

# Install system dependencies required for PostgreSQL connectivity
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy backend application source code
COPY . /app

# Create a non-privileged user for security compliance on Cloud Run
RUN useradd -u 1001 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose standard Cloud Run container port
EXPOSE 8080

# Run uvicorn server binding dynamically to Cloud Run $PORT
CMD exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 2
