#!/bin/bash
# Development server with hot-reload for FastAPI + Svelte
set -e

echo "🚀 Starting development environment with hot-reload..."
echo "📡 Backend: http://localhost:${BACKEND_PORT:-8000}"
echo "🌐 Frontend: http://localhost:${FRONTEND_PORT:-5173}"
echo "🏥 Health check: http://localhost:${BACKEND_PORT:-8000}/health"
echo ""
echo "Press Ctrl+C to stop"
echo "--------------------------------------------------"

docker compose -f docker-compose.dev.yml up --build
