
# DevOps-Assignment-1-ACEestFitness

End-to-end DevOps pipeline for a simple Flask app for **ACEest Fitness & Gym**.

## 📦 Tech
- Flask (API)
- Pytest (tests)
- Docker (containerization)
- GitHub Actions (CI)

---

## 🚀 Run locally

```bash
python -m venv .venv && source .venv/bin/activate  # (Linux/Mac)
# Windows: py -m venv .venv && .venv\Scripts\activate

pip install -r requirements.txt
python app.py
# App on http://localhost:5000
```

## ✅ Run tests
```bash
pytest -q
```

## 🐳 Docker
```bash
docker build -t aceest_fitness .
docker run -p 5000:5000 aceest_fitness
# Visit http://localhost:5000
```

## 🔁 CI (GitHub Actions)
On every push / PR, the workflow will:
1. Install deps
2. Run tests
3. Build Docker image

See `.github/workflows/ci.yml`.

---

## 📂 Project layout
```text
.
├── app.py
├── requirements.txt
├── tests
│   └── test_app.py
├── Dockerfile
├── .dockerignore
└── .github
    └── workflows
        └── ci.yml
```

## ✍️ Notes
- This repository implements the deliverables described in the assignment:
  - Flask app + API
  - Pytest unit tests
  - Dockerfile
  - GitHub Actions workflow
  - README with instructions
