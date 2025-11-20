#!/bin/bash

# Improved rapid deployment script for FastAPI + Svelte projects
# This version uses a .env file for configuration, avoiding brittle 'sed' commands.
set -e

# --- Configuration ---
# The path to your local template directory, relative to where this script is run.
TEMPLATE_DIR="../my-project-template"

# --- Get Project Details ---
read -p "Enter project name: " PROJECT_NAME
read -p "Enter backend port (default 8000): " BACKEND_PORT
read -p "Enter frontend port (default 5173): " FRONTEND_PORT

# Set defaults if input is empty
BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

echo "🚀 Creating project: $PROJECT_NAME"
echo "📡 Backend port: $BACKEND_PORT"
echo "🌐 Frontend port: $FRONTEND_PORT"

# --- Project Scaffolding ---

# Check if template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ Error: Template directory not found at '$TEMPLATE_DIR'"
    echo "Please update the TEMPLATE_DIR variable in this script."
    exit 1
fi

# Copy template to the new project directory
echo "📋 Copying template..."
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"
cd "$PROJECT_NAME"

# --- Environment Configuration ---

echo "🔧 Configuring environment..."
# Create the .env file from the example template
# Using a here-document (cat <<EOL) is safer and clearer than multiple sed commands.
cat > .env <<EOL
# Project-specific environment variables
PROJECT_NAME=${PROJECT_NAME}

# Database
# Using a unique database name for the project
DATABASE_URL=postgresql://user:password@db:5432/${PROJECT_NAME}_db

# Ports
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}

# API Configuration for SvelteKit/Vite
# The frontend will consume this variable
VITE_API_URL=http://localhost:${BACKEND_PORT}

# Server-side internal API URL
# Inside Docker network, backend is reachable at http://backend:8000
# (assuming standard internal port 8000 for FastAPI)
API_BASE_URL=http://backend:8000

# CORS Configuration
# Allow requests from the frontend and the backend itself (for Swagger UI)
CORS_ORIGINS=http://localhost:${FRONTEND_PORT},http://localhost:${BACKEND_PORT}

# Public URL
PUBLIC_URL=http://localhost:${FRONTEND_PORT}
EOL

# --- Git & GitHub Setup ---

echo "📦 Initializing Git repository..."
git init
git add .
git commit -m "Initial setup of $PROJECT_NAME"

echo "🌍 Creating GitHub repository..."
# The 'gh' command handles remote setup and initial push
gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --push

echo "🌿 Setting up development branch..."
git checkout -b development
git push -u origin development

# --- Deployment ---

echo "🐳 Starting containers via Docker Compose..."
# Docker Compose automatically finds and uses the .env file in the current directory
docker compose up -d --build

# --- Success ---

echo "✅ Project deployed successfully!"
echo "--------------------------------------------------"
echo "🔗 Repository: https://github.com/$(gh auth status -h github.com --show-token | awk '{print $5}')/$PROJECT_NAME"
echo "🌐 Frontend running at: http://localhost:$FRONTEND_PORT"
echo "📡 Backend running at: http://localhost:$BACKEND_PORT"
echo "--------------------------------------------------"
