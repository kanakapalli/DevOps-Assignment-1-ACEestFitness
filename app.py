
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

# In-memory store (kept simple for the assignment)
WORKOUTS = []

HOME_HTML = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ACEest Fitness</title>
</head>
<body>
  <h1>ACEest Fitness & Gym</h1>
  <p>Welcome! Use the API to add and view workouts.</p>
  <ul>
    <li>POST /workouts  (JSON: {"workout": "Running", "duration": 30})</li>
    <li>GET  /workouts</li>
  </ul>
</body>
</html>
"""

@app.get("/")
def home():
    return render_template_string(HOME_HTML), 200

@app.post("/workouts")
def add_workout():
    data = request.get_json(silent=True) or {}
    workout = (data.get("workout") or "").strip()
    duration = data.get("duration")

    if not workout:
        return jsonify({"error": "workout is required"}), 400
    try:
        duration = int(duration)
        if duration <= 0:
            raise ValueError
    except Exception:
        return jsonify({"error": "duration must be a positive integer"}), 400

    entry = {"workout": workout, "duration": duration}
    WORKOUTS.append(entry)
    return jsonify(entry), 201

@app.get("/workouts")
def list_workouts():
    return jsonify({"count": len(WORKOUTS), "items": WORKOUTS}), 200

if __name__ == "__main__":
    # Bind to 0.0.0.0 for Docker
    app.run(host="0.0.0.0", port=5000, debug=False)
