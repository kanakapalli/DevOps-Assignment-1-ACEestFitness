"""
Comprehensive Unit Tests for ACEest Fitness & Gym Tracker API
Tests all endpoints with various scenarios including edge cases
"""

import pytest
import json
from aceest_fitness_app import app, workouts_db, users_db

@pytest.fixture
def client():
    """Create a test client for the Flask application"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        # Reset databases before each test
        workouts_db["Warm-up"] = []
        workouts_db["Workout"] = []
        workouts_db["Cool-down"] = []
        users_db.clear()
        yield client

@pytest.fixture
def sample_user():
    """Sample user data for testing"""
    return {
        "user_id": "test_user_001",
        "name": "John Doe",
        "age": 30,
        "gender": "M",
        "height": 175,
        "weight": 75
    }

@pytest.fixture
def sample_workout():
    """Sample workout data for testing"""
    return {
        "category": "Workout",
        "exercise": "Push-ups",
        "duration": 30,
        "user_id": "test_user_001"
    }

# ==================== Home Endpoint Tests ====================

def test_home_endpoint(client):
    """Test the home endpoint returns API information"""
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['service'] == "ACEest Fitness & Gym Tracker API"
    assert data['version'] == "1.3.0"
    assert data['status'] == "healthy"
    assert 'endpoints' in data

# ==================== User Management Tests ====================

def test_create_user_success(client, sample_user):
    """Test successful user creation"""
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['message'] == "User profile created successfully"
    assert data['user']['name'] == "John Doe"
    assert 'bmi' in data['user']
    assert 'bmr' in data['user']

def test_create_user_missing_fields(client):
    """Test user creation with missing required fields"""
    incomplete_user = {"user_id": "test_001", "name": "John"}
    response = client.post('/users',
                           data=json.dumps(incomplete_user),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Missing required fields' in data['error']

def test_create_user_invalid_age(client, sample_user):
    """Test user creation with invalid age"""
    sample_user['age'] = -5
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_create_user_invalid_gender(client, sample_user):
    """Test user creation with invalid gender"""
    sample_user['gender'] = 'X'
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Gender must be' in data['error']

def test_create_user_female_bmr(client, sample_user):
    """Test BMR calculation for female user"""
    sample_user['gender'] = 'F'
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['user']['gender'] == 'F'
    assert 'bmr' in data['user']

def test_create_user_empty_name(client, sample_user):
    """Test user creation with empty name"""
    sample_user['name'] = "   "
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_create_user_no_data(client):
    """Test user creation with no data"""
    response = client.post('/users',
                           data=json.dumps({}),
                           content_type='application/json')
    assert response.status_code == 400

def test_get_user_success(client, sample_user):
    """Test retrieving an existing user"""
    # First create a user
    client.post('/users',
                data=json.dumps(sample_user),
                content_type='application/json')

    # Then retrieve it
    response = client.get(f"/users/{sample_user['user_id']}")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['user_id'] == sample_user['user_id']
    assert data['name'] == sample_user['name']

def test_get_user_not_found(client):
    """Test retrieving a non-existent user"""
    response = client.get('/users/nonexistent_user')
    assert response.status_code == 404
    data = json.loads(response.data)
    assert 'error' in data
    assert 'User not found' in data['error']

# ==================== Workout Management Tests ====================

def test_add_workout_success(client, sample_workout):
    """Test successfully adding a workout"""
    response = client.post('/workouts',
                           data=json.dumps(sample_workout),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['message'] == f"Workout '{sample_workout['exercise']}' added successfully to {sample_workout['category']}"
    assert data['workout']['exercise'] == sample_workout['exercise']
    assert data['workout']['duration'] == sample_workout['duration']
    assert 'calories' in data['workout']
    assert 'timestamp' in data['workout']

def test_add_workout_missing_exercise(client):
    """Test adding workout without exercise name"""
    workout = {"category": "Workout", "duration": 30}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Exercise name is required' in data['error']

def test_add_workout_empty_exercise(client):
    """Test adding workout with empty exercise name"""
    workout = {"category": "Workout", "exercise": "   ", "duration": 30}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_add_workout_invalid_category(client):
    """Test adding workout with invalid category"""
    workout = {"category": "InvalidCategory", "exercise": "Running", "duration": 30}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Invalid category' in data['error']

def test_add_workout_invalid_duration(client):
    """Test adding workout with invalid duration"""
    workout = {"category": "Workout", "exercise": "Running", "duration": "abc"}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data
    assert 'Duration must be' in data['error']

def test_add_workout_negative_duration(client):
    """Test adding workout with negative duration"""
    workout = {"category": "Workout", "exercise": "Running", "duration": -10}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_add_workout_zero_duration(client):
    """Test adding workout with zero duration"""
    workout = {"category": "Workout", "exercise": "Running", "duration": 0}
    response = client.post('/workouts',
                           data=json.dumps(workout),
                           content_type='application/json')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_add_workout_with_user_calories(client, sample_user, sample_workout):
    """Test calorie calculation with user-specific weight"""
    # Create user first
    client.post('/users',
                data=json.dumps(sample_user),
                content_type='application/json')

    # Add workout
    response = client.post('/workouts',
                           data=json.dumps(sample_workout),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['workout']['calories'] > 0

def test_add_multiple_workouts(client):
    """Test adding multiple workouts"""
    workouts = [
        {"category": "Warm-up", "exercise": "Stretching", "duration": 10},
        {"category": "Workout", "exercise": "Running", "duration": 30},
        {"category": "Cool-down", "exercise": "Walking", "duration": 5}
    ]

    for workout in workouts:
        response = client.post('/workouts',
                               data=json.dumps(workout),
                               content_type='application/json')
        assert response.status_code == 201

def test_get_all_workouts_empty(client):
    """Test getting all workouts when none exist"""
    response = client.get('/workouts')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert "Warm-up" in data
    assert "Workout" in data
    assert "Cool-down" in data
    assert len(data["Warm-up"]) == 0

def test_get_all_workouts_with_data(client, sample_workout):
    """Test getting all workouts after adding some"""
    # Add a workout
    client.post('/workouts',
                data=json.dumps(sample_workout),
                content_type='application/json')

    # Get all workouts
    response = client.get('/workouts')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert len(data["Workout"]) == 1
    assert data["Workout"][0]["exercise"] == sample_workout["exercise"]

def test_get_workouts_by_category_success(client, sample_workout):
    """Test getting workouts by specific category"""
    # Add a workout
    client.post('/workouts',
                data=json.dumps(sample_workout),
                content_type='application/json')

    # Get by category
    response = client.get('/workouts/Workout')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['category'] == 'Workout'
    assert data['total_count'] == 1
    assert len(data['workouts']) == 1

def test_get_workouts_by_invalid_category(client):
    """Test getting workouts by invalid category"""
    response = client.get('/workouts/InvalidCategory')
    assert response.status_code == 404
    data = json.loads(response.data)
    assert 'error' in data

# ==================== Progress Tracking Tests ====================

def test_get_progress_no_workouts(client):
    """Test getting progress when no workouts exist"""
    response = client.get('/progress')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['total_workouts'] == 0
    assert 'message' in data

def test_get_progress_with_workouts(client):
    """Test getting progress after adding workouts"""
    workouts = [
        {"category": "Warm-up", "exercise": "Stretching", "duration": 10},
        {"category": "Workout", "exercise": "Running", "duration": 30},
        {"category": "Workout", "exercise": "Cycling", "duration": 20}
    ]

    for workout in workouts:
        client.post('/workouts',
                    data=json.dumps(workout),
                    content_type='application/json')

    response = client.get('/progress')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['total_workouts'] == 3
    assert data['total_duration'] == 60
    assert 'by_category' in data
    assert data['by_category']['Workout']['count'] == 2
    assert data['by_category']['Warm-up']['count'] == 1

def test_get_user_progress_no_workouts(client):
    """Test getting user progress when no workouts exist"""
    response = client.get('/progress/test_user')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['user_id'] == 'test_user'
    assert data['total_workouts'] == 0

def test_get_user_progress_with_workouts(client, sample_user, sample_workout):
    """Test getting user-specific progress"""
    # Create user and add workouts
    client.post('/users',
                data=json.dumps(sample_user),
                content_type='application/json')

    client.post('/workouts',
                data=json.dumps(sample_workout),
                content_type='application/json')

    response = client.get(f"/progress/{sample_user['user_id']}")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['user_id'] == sample_user['user_id']
    assert data['total_workouts'] == 1
    assert data['total_duration'] == 30

def test_clear_workouts(client, sample_workout):
    """Test clearing all workouts"""
    # Add a workout
    client.post('/workouts',
                data=json.dumps(sample_workout),
                content_type='application/json')

    # Clear workouts
    response = client.delete('/workouts')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'message' in data
    assert 'cleared successfully' in data['message']

    # Verify workouts are cleared
    response = client.get('/workouts')
    data = json.loads(response.data)
    assert len(data["Warm-up"]) == 0
    assert len(data["Workout"]) == 0
    assert len(data["Cool-down"]) == 0

# ==================== Integration Tests ====================

def test_complete_user_workflow(client, sample_user, sample_workout):
    """Test a complete user workflow: create user, add workouts, check progress"""
    # Step 1: Create user
    response = client.post('/users',
                           data=json.dumps(sample_user),
                           content_type='application/json')
    assert response.status_code == 201

    # Step 2: Add multiple workouts
    workouts = [
        {"category": "Warm-up", "exercise": "Stretching", "duration": 10, "user_id": sample_user['user_id']},
        {"category": "Workout", "exercise": "Push-ups", "duration": 20, "user_id": sample_user['user_id']},
        {"category": "Workout", "exercise": "Squats", "duration": 25, "user_id": sample_user['user_id']},
        {"category": "Cool-down", "exercise": "Walking", "duration": 5, "user_id": sample_user['user_id']}
    ]

    for workout in workouts:
        response = client.post('/workouts',
                               data=json.dumps(workout),
                               content_type='application/json')
        assert response.status_code == 201

    # Step 3: Check overall progress
    response = client.get('/progress')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['total_workouts'] == 4
    assert data['total_duration'] == 60

    # Step 4: Check user-specific progress
    response = client.get(f"/progress/{sample_user['user_id']}")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['total_workouts'] == 4
    assert data['by_category']['Workout']['count'] == 2

    # Step 5: Get user info
    response = client.get(f"/users/{sample_user['user_id']}")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['name'] == sample_user['name']

# ==================== Run Tests ====================

if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
