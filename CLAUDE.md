# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ACEest Fitness is a fitness tracking application demonstrating DevOps practices. The project consists of two independent applications:
1. **Flask REST API** (`app.py`) - Web-based workout tracking service
2. **Tkinter Desktop GUI** (`gui_app.py`) - Standalone desktop workout tracker

Both applications maintain their own in-memory workout storage and do not communicate with each other.

## Common Commands

### Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run Flask web application (http://localhost:5000)
python app.py

# Run Tkinter desktop application
python gui_app.py
```

### Testing
```bash
# Run all tests
pytest -q

# Run specific test file
pytest tests/test_app.py -v
```

### Docker
```bash
# Build image
docker build -t aceest_fitness .

# Run container (Flask app only)
docker run -p 5000:5000 aceest_fitness
```

## Architecture

### Flask Application (`app.py`)
- Simple REST API with three endpoints: `GET /`, `POST /workouts`, `GET /workouts`
- In-memory storage using `WORKOUTS` list (resets on restart)
- Input validation: workout name required (non-empty string), duration must be positive integer
- Returns JSON responses with appropriate HTTP status codes (200, 201, 400)
- Binds to `0.0.0.0:5000` for Docker compatibility

### Tkinter Application (`gui_app.py`)
- Standalone desktop GUI using `FitnessTrackerApp` class
- Local in-memory storage (separate from Flask app)
- Two main operations: add workout (validates inputs) and view workouts (displays in messagebox)
- Does NOT connect to Flask API - completely independent

### Test Suite (`tests/test_app.py`)
- Tests Flask app only (no GUI tests)
- Uses Flask's test client for endpoint testing
- Tests accumulate workouts across test functions (shared `WORKOUTS` state)
- Validates home page, workout addition, input validation, and workout listing

### CI/CD Pipeline (`.github/workflows/ci.yml`)
- Triggers on push/PR to main branch
- Runs on Ubuntu with Python 3.11
- Steps: install dependencies → run pytest → build Docker image
- Note: Only Flask app is tested and containerized

## Key Implementation Details

### Data Storage
Both applications use in-memory storage with no persistence. Data is lost when the application restarts. The Flask and Tkinter apps do not share data.

### Workout Data Structure
```python
{"workout": "Running", "duration": 30}
```

### Flask API Validation Rules
- Workout name: must be non-empty after stripping whitespace
- Duration: must be positive integer (>0)
- Returns 400 error with JSON error message on validation failure

### Docker Configuration
- Based on `python:3.11-slim`
- Working directory: `/app`
- Exposes port 5000
- Only runs Flask app (`python app.py`)
- Tkinter GUI not containerized (requires display)

## Assignment Context

This is Assignment 1 focusing on basic Flask/Tkinter development, testing, and Docker containerization. Assignment 2 materials exist in separate directory but are not part of the main codebase.
