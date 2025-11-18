from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import os

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
origins = [
    "http://localhost:5173",
    "http://localhost:3000",
    "http://127.0.0.1:5173",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
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

# Example endpoint
@app.get("/api/hello")
async def hello(name: str = "World"):
    return {
        "message": f"Hello, {name}!",
        "timestamp": None
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("BACKEND_PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
