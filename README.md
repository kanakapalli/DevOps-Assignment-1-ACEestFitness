# ACEest Fitness & Gym - DevOps Assignment

A fitness tracking application built with Flask (web API) and Tkinter (desktop GUI), demonstrating DevOps practices including CI/CD, containerization, and testing.

## Project Overview

This project implements a simple fitness tracking system that allows users to log and view their workout sessions. It consists of two main components:

1. **Flask Web API** (`app.py`) - REST API for workout management
2. **Tkinter Desktop GUI** (`gui_app.py`) - Desktop application for workout tracking

## Features

### Flask Web Application
- **Home Page**: Welcome page with API usage instructions
- **Add Workout**: POST endpoint to add new workout entries
- **View Workouts**: GET endpoint to retrieve all logged workouts
- **Input Validation**: Validates workout names and duration values
- **JSON API**: RESTful API with JSON request/response format

### Tkinter Desktop Application
- **GUI Interface**: User-friendly desktop application
- **Add Workouts**: Form to input workout name and duration
- **View Workouts**: Display all logged workouts in a popup
- **Error Handling**: Input validation with user-friendly error messages

## Technical Stack

- **Backend**: Python Flask
- **Frontend**: Tkinter (GUI), HTML (Web)
- **Testing**: pytest
- **Containerization**: Docker
- **CI/CD**: GitHub Actions
- **Dependencies**: Flask, pytest

## Project Structure

```
DevOps-Assignment-1-ACEestFitness/
├── app.py                 # Flask web application
├── gui_app.py            # Tkinter desktop application
├── requirements.txt      # Python dependencies
├── Dockerfile           # Docker container configuration
├── tests/
│   └── test_app.py      # Unit tests for Flask app
├── .github/
│   └── workflows/
│       └── ci.yml       # GitHub Actions CI/CD pipeline
├── .gitignore          # Git ignore rules
└── README.md           # Project documentation
```

## Getting Started

### Prerequisites
- Python 3.11+
- pip (Python package installer)
- Docker (optional, for containerization)

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd DevOps-Assignment-1-ACEestFitness
   ```

2. **Create virtual environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

### Running the Applications

#### Flask Web Application
```bash
python app.py
```
The web application will be available at `http://localhost:5000`

**API Endpoints:**
- `GET /` - Home page with API documentation
- `POST /workouts` - Add a new workout
  ```json
  {
    "workout": "Running",
    "duration": 30
  }
  ```
- `GET /workouts` - Retrieve all workouts

#### Tkinter Desktop Application
```bash
python gui_app.py
```

### Testing

Run the test suite:
```bash
pytest -q
```

The test suite includes:
- Home page functionality test
- Workout addition with validation
- Workout listing functionality
- Input validation testing

### Docker Deployment

#### Build Docker Image
```bash
docker build -t aceest_fitness .
```

#### Run Docker Container
```bash
docker run -p 5000:5000 aceest_fitness
```

The containerized application will be available at `http://localhost:5000`

## CI/CD Pipeline

The project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:

1. **Triggers on**: Push and pull requests to main branch
2. **Environment**: Ubuntu latest with Python 3.11
3. **Steps**:
   - Checkout code
   - Set up Python environment
   - Install dependencies
   - Run test suite
   - Build Docker image

### Pipeline Status
The CI/CD pipeline automatically:
- Validates code quality through testing
- Ensures Docker image builds successfully
- Provides feedback on pull requests

## Development Guidelines

### Code Quality
- Follow PEP 8 Python style guidelines
- Write unit tests for new features
- Ensure all tests pass before committing
- Use meaningful commit messages

### Adding New Features
1. Create a feature branch
2. Implement the feature with tests
3. Ensure CI pipeline passes
4. Submit a pull request

## API Usage Examples

### Add a Workout
```bash
curl -X POST http://localhost:5000/workouts \
  -H "Content-Type: application/json" \
  -d '{"workout": "Yoga", "duration": 45}'
```

### Get All Workouts
```bash
curl http://localhost:5000/workouts
```

## Docker Configuration

The Dockerfile:
- Uses Python 3.11 slim base image
- Sets up working directory at `/app`
- Installs dependencies from `requirements.txt`
- Exposes port 5000
- Runs the Flask application

## Troubleshooting

### Common Issues

1. **Module not found errors**: Ensure virtual environment is activated and dependencies are installed
2. **Port already in use**: Change the port in `app.py` or stop the conflicting process
3. **Docker build fails**: Check Dockerfile syntax and ensure Docker daemon is running
4. **Tests failing**: Check that Flask app is not running on the same port during testing

### Dependencies

Core dependencies:
- `flask`: Web framework for API development
- `pytest`: Testing framework for unit tests

## Future Enhancements

- Database integration for persistent storage
- User authentication and authorization
- Web frontend with modern JavaScript framework
- Advanced workout analytics and reporting
- Mobile application development
- API rate limiting and security enhancements

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## License

This project is created for educational purposes as part of a DevOps assignment.

---

**Assignment Completion Status**: ✅ All requirements implemented
- ✅ Flask web application with API endpoints
- ✅ Tkinter desktop GUI application
- ✅ Unit tests with pytest
- ✅ Docker containerization
- ✅ GitHub Actions CI/CD pipeline
- ✅ Comprehensive documentation