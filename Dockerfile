# Multi-stage Dockerfile for ACEest Fitness & Gym Tracker
# Base image with Python 3.11
FROM python:3.11-slim

# Set maintainer label
LABEL maintainer="aceest-fitness-team"
LABEL version="1.3.0"
LABEL description="ACEest Fitness & Gym Tracker REST API"

# Prevent Python from writing .pyc files and buffering stdout/err
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

# Create non-root user for security
RUN useradd -m -u 1000 appuser

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt ./

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY aceest_fitness_app.py ./

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')"

# Run the application
CMD ["python", "aceest_fitness_app.py"]
