
import json
from app import app

def test_home_status_and_content():
    client = app.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert b"ACEest Fitness & Gym" in res.data

def test_add_workout_success():
    client = app.test_client()
    payload = {"workout": "Running", "duration": 30}
    res = client.post("/workouts", data=json.dumps(payload), content_type="application/json")
    assert res.status_code == 201
    data = res.get_json()
    assert data["workout"] == "Running"
    assert data["duration"] == 30

def test_add_workout_validation():
    client = app.test_client()
    # Missing workout
    res1 = client.post("/workouts", json={"duration": 10})
    assert res1.status_code == 400
    # Invalid duration
    res2 = client.post("/workouts", json={"workout": "Yoga", "duration": 0})
    assert res2.status_code == 400

def test_list_workouts():
    client = app.test_client()
    # Ensure there's at least one entry from previous test; add one more
    client.post("/workouts", json={"workout": "Cycling", "duration": 45})
    res = client.get("/workouts")
    assert res.status_code == 200
    data = res.get_json()
    assert "count" in data and "items" in data
    assert data["count"] == len(data["items"])
    assert any(item["workout"] == "Cycling" for item in data["items"])
