#!/bin/bash
# Rapid deployment script for FastAPI + Svelte projects
# Creates project in current directory with .env configuration
set -e

# --- Configuration ---
TEMPLATE_DIR="../my-project-template"

# --- Get Project Details ---
read -p "Enter backend port (default 8000): " BACKEND_PORT
read -p "Enter frontend port (default 5173): " FRONTEND_PORT

# Set defaults if input is empty
BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

echo "🚀 Configuring project"
echo "📡 Backend port: $BACKEND_PORT"
echo "🌐 Frontend port: $FRONTEND_PORT"

# --- Environment Configuration ---
echo "🔧 Generating .env file..."
cat > .env <<EOL
# Project environment variables
DATABASE_URL=postgresql://postgres:1122@db:5432/myapp_db
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOL

echo "✅ .env created"

# --- Git Setup ---
echo "📦 Initializing Git repository..."
git init
git add .
git commit -m "Initial FastAPI + Svelte setup"

echo "🌍 Creating GitHub repository..."
gh repo create --public --source=. --remote=origin --push

echo "🌿 Setting up development branch..."
git checkout -b development
git push -u origin development

# --- Deployment ---
echo "🐳 Starting Docker Compose..."
docker compose up -d --build

# --- Success ---
echo "✅ Project deployed successfully!"
echo "--------------------------------------------------"
echo "🌐 Frontend: http://localhost:$FRONTEND_PORT"
echo "📡 Backend: http://localhost:$BACKEND_PORT"
echo "🏥 Health check: http://localhost:$BACKEND_PORT/health"
echo "--------------------------------------------------"
