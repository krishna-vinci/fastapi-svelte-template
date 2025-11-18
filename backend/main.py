from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncpg
import os
import time

# Lifecycle events
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 FastAPI starting...")
    yield
    # Shutdown
    print("🛑 FastAPI shutting down...")

# Initialize FastAPI app
app = FastAPI(
    title="FastAPI Backend",
    description="FastAPI + Svelte + shadcn/ui Backend",
    version="1.0.0",
    lifespan=lifespan
)

# CORS configuration
def build_allowed_origins() -> list[str]:
    raw = os.getenv("CORS_ALLOW_ORIGINS")
    if raw:
        if raw.strip() == "*":
            return ["*"]
        return [origin.strip() for origin in raw.split(",") if origin.strip()]

    return ["*"]


origins = build_allowed_origins()
allow_all_origins = origins == ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if allow_all_origins else origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "message": "FastAPI backend is running"
    }

# Database health helper
async def check_database_connection() -> dict:
    database_url = os.getenv("DATABASE_URL", "postgresql://postgres:1122@db:5432/postgres")
    start_time = time.perf_counter()
    try:
        conn = await asyncpg.connect(database_url)
        await conn.execute("SELECT 1;")
        await conn.close()
        latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
        return {
            "status": "ok",
            "latency_ms": latency_ms
        }
    except Exception as exc:  # pragma: no cover - simple diagnostic path
        return {
            "status": "error",
            "message": str(exc)
        }


@app.get("/api/status")
async def service_status():
    db_status = await check_database_connection()
    overall = "ok" if db_status["status"] == "ok" else "degraded"
    return {
        "backend": overall,
        "database": db_status
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("BACKEND_PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
