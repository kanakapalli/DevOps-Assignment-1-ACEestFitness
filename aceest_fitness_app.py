"""
ACEest Fitness & Gym Tracker - Flask REST API
Version: 1.3.0
Description: Complete fitness tracking system with workout logging, progress tracking, and user management
"""

from flask import Flask, request, jsonify
from datetime import datetime, date
import os

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

# In-memory storage
workouts_db = {
    "Warm-up": [],
    "Workout": [],
    "Cool-down": []
}

users_db = {}

# MET Values for calorie calculations
MET_VALUES = {
    "Warm-up": 3,
    "Workout": 6,
    "Cool-down": 2.5
}

@app.route('/', methods=['GET'])
def home():
    """Health check and API information endpoint"""
    return jsonify({
        "service": "ACEest Fitness & Gym Tracker API",
        "version": "1.3.0",
        "status": "healthy",
        "endpoints": {
            "GET /": "API information",
            "POST /users": "Create or update user profile",
            "GET /users/<user_id>": "Get user profile",
            "POST /workouts": "Add a workout session",
            "GET /workouts": "Get all workouts",
            "GET /workouts/<category>": "Get workouts by category",
            "GET /progress": "Get workout progress statistics",
            "GET /progress/<user_id>": "Get user-specific progress",
            "DELETE /workouts": "Clear all workouts"
        }
    }), 200

@app.route('/users', methods=['POST'])
def create_user():
    """Create or update user profile"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    required_fields = ['user_id', 'name', 'age', 'gender', 'height', 'weight']
    missing_fields = [field for field in required_fields if field not in data]

    if missing_fields:
        return jsonify({"error": f"Missing required fields: {', '.join(missing_fields)}"}), 400

    try:
        user_id = data['user_id']
        name = str(data['name']).strip()
        age = int(data['age'])
        gender = str(data['gender']).strip().upper()
        height_cm = float(data['height'])
        weight_kg = float(data['weight'])

        if not name:
            return jsonify({"error": "Name cannot be empty"}), 400

        if age <= 0 or age > 150:
            return jsonify({"error": "Age must be between 1 and 150"}), 400

        if gender not in ['M', 'F']:
            return jsonify({"error": "Gender must be 'M' or 'F'"}), 400

        if height_cm <= 0 or height_cm > 300:
            return jsonify({"error": "Height must be between 1 and 300 cm"}), 400

        if weight_kg <= 0 or weight_kg > 500:
            return jsonify({"error": "Weight must be between 1 and 500 kg"}), 400

        # Calculate BMI and BMR
        bmi = weight_kg / ((height_cm / 100) ** 2)

        if gender == "M":
            bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
        else:
            bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age - 161

        users_db[user_id] = {
            "user_id": user_id,
            "name": name,
            "age": age,
            "gender": gender,
            "height_cm": height_cm,
            "weight_kg": weight_kg,
            "bmi": round(bmi, 2),
            "bmr": round(bmr, 0),
            "created_at": datetime.now().isoformat()
        }

        return jsonify({
            "message": "User profile created successfully",
            "user": users_db[user_id]
        }), 201

    except (ValueError, TypeError) as e:
        return jsonify({"error": f"Invalid data format: {str(e)}"}), 400

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    """Get user profile by user_id"""
    if user_id not in users_db:
        return jsonify({"error": "User not found"}), 404

    return jsonify(users_db[user_id]), 200

@app.route('/workouts', methods=['POST'])
def add_workout():
    """Add a new workout session"""
    data = request.get_json()

    if not data:
        return jsonify({"error": "No data provided"}), 400

    category = data.get('category', '').strip()
    exercise = data.get('exercise', '').strip()
    duration = data.get('duration')
    user_id = data.get('user_id', 'default')

    if not exercise:
        return jsonify({"error": "Exercise name is required"}), 400

    if category not in workouts_db:
        return jsonify({"error": f"Invalid category. Must be one of: {list(workouts_db.keys())}"}), 400

    try:
        duration = int(duration)
        if duration <= 0:
            return jsonify({"error": "Duration must be a positive integer"}), 400
    except (ValueError, TypeError):
        return jsonify({"error": "Duration must be a valid positive integer"}), 400

    # Calculate calories
    weight = 70  # default weight
    if user_id in users_db:
        weight = users_db[user_id]['weight_kg']

    met = MET_VALUES.get(category, 5)
    calories = round((met * 3.5 * weight / 200) * duration, 2)

    workout_entry = {
        "id": len(workouts_db[category]) + 1,
        "user_id": user_id,
        "exercise": exercise,
        "duration": duration,
        "calories": calories,
        "timestamp": datetime.now().isoformat(),
        "date": date.today().isoformat()
    }

    workouts_db[category].append(workout_entry)

    return jsonify({
        "message": f"Workout '{exercise}' added successfully to {category}",
        "workout": workout_entry
    }), 201

@app.route('/workouts', methods=['GET'])
def get_all_workouts():
    """Get all workouts across all categories"""
    return jsonify(workouts_db), 200

@app.route('/workouts/<category>', methods=['GET'])
def get_workouts_by_category(category):
    """Get workouts by specific category"""
    if category not in workouts_db:
        return jsonify({"error": f"Invalid category. Must be one of: {list(workouts_db.keys())}"}), 404

    return jsonify({
        "category": category,
        "workouts": workouts_db[category],
        "total_count": len(workouts_db[category])
    }), 200

@app.route('/progress', methods=['GET'])
def get_progress():
    """Get overall workout progress statistics"""
    total_workouts = sum(len(workouts) for workouts in workouts_db.values())

    if total_workouts == 0:
        return jsonify({
            "message": "No workouts logged yet",
            "total_workouts": 0
        }), 200

    stats = {}
    total_duration = 0
    total_calories = 0

    for category, workouts in workouts_db.items():
        category_duration = sum(w['duration'] for w in workouts)
        category_calories = sum(w['calories'] for w in workouts)

        stats[category] = {
            "count": len(workouts),
            "total_duration": category_duration,
            "total_calories": round(category_calories, 2)
        }

        total_duration += category_duration
        total_calories += category_calories

    return jsonify({
        "total_workouts": total_workouts,
        "total_duration": total_duration,
        "total_calories": round(total_calories, 2),
        "by_category": stats
    }), 200

@app.route('/progress/<user_id>', methods=['GET'])
def get_user_progress(user_id):
    """Get workout progress for a specific user"""
    user_workouts = {"Warm-up": [], "Workout": [], "Cool-down": []}

    for category, workouts in workouts_db.items():
        user_workouts[category] = [w for w in workouts if w['user_id'] == user_id]

    total_workouts = sum(len(workouts) for workouts in user_workouts.values())

    if total_workouts == 0:
        return jsonify({
            "user_id": user_id,
            "message": "No workouts logged yet for this user",
            "total_workouts": 0
        }), 200

    stats = {}
    total_duration = 0
    total_calories = 0

    for category, workouts in user_workouts.items():
        category_duration = sum(w['duration'] for w in workouts)
        category_calories = sum(w['calories'] for w in workouts)

        stats[category] = {
            "count": len(workouts),
            "total_duration": category_duration,
            "total_calories": round(category_calories, 2),
            "workouts": workouts
        }

        total_duration += category_duration
        total_calories += category_calories

    return jsonify({
        "user_id": user_id,
        "total_workouts": total_workouts,
        "total_duration": total_duration,
        "total_calories": round(total_calories, 2),
        "by_category": stats
    }), 200

@app.route('/workouts', methods=['DELETE'])
def clear_workouts():
    """Clear all workout data (for testing purposes)"""
    global workouts_db
    workouts_db = {
        "Warm-up": [],
        "Workout": [],
        "Cool-down": []
    }
    return jsonify({"message": "All workouts cleared successfully"}), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
