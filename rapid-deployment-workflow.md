# Rapid FastAPI + Svelte + shadcn/ui Deployment Workflow

## Overview
Automated workflow to create and deploy FastAPI + Svelte projects with shadcn/ui components in under 30 seconds using a robust, environment-variable-based configuration.

## Prerequisites
- Git
- Docker & Docker Compose
- GitHub CLI (`gh`) authenticated
- Local template repository

## One-Time Template Setup

### 1. Create Template Repository
```bash
# Clone a base template and configure it once
git clone https://github.com/your-template/fastapi-svelte-template my-project-template
cd my-project-template

# Configure with:
# - FastAPI backend structure
# - SvelteKit frontend with shadcn/ui
# - Docker Compose configuration using .env files
# - Placeholder ports (8000, 5173)

# Remove the original remote to make it a local-only template
git remote remove origin
```

### 2. Template Structure
The template is simplified by removing the port-changing script.
```
my-project-template/
├── backend/
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── docker-compose.yml
└── .env.example
```

## Per-Project Deployment Script (`deploy.sh`)
This single script handles project creation, configuration, and deployment.

```bash
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
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ Error: Template directory not found at '$TEMPLATE_DIR'"
    exit 1
fi

echo "📋 Copying template..."
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"
cd "$PROJECT_NAME"

# --- Environment Configuration ---
echo "🔧 Configuring environment..."
cat > .env <<EOL
# Project-specific environment variables
DATABASE_URL=postgresql://user:password@db:5432/${PROJECT_NAME}_db
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOL

# --- Git & GitHub Setup ---
echo "📦 Initializing Git repository..."
git init
git add .
git commit -m "Initial setup of $PROJECT_NAME"

echo "🌍 Creating GitHub repository..."
gh repo create "$PROJECT_NAME" --public --source=. --remote=origin --push

echo "🌿 Setting up development branch..."
git checkout -b development
git push -u origin development

# --- Deployment ---
echo "🐳 Starting containers via Docker Compose..."
docker compose up -d --build

# --- Success ---
echo "✅ Project deployed successfully!"
echo "--------------------------------------------------"
echo "🔗 Repository: https://github.com/$(gh auth status -h github.com --show-token | awk '{print $5}')/$PROJECT_NAME"
echo "🌐 Frontend running at: http://localhost:$FRONTEND_PORT"
echo "📡 Backend running at: http://localhost:$BACKEND_PORT"
echo "--------------------------------------------------"
```

## Docker Compose Template (`docker-compose.yml`)
The Compose file now uses variables from the `.env` file, making it flexible without needing modification.

```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "${BACKEND_PORT:-8000}:8000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - BACKEND_PORT=${BACKEND_PORT:-8000}
    depends_on:
      - db
    restart: unless-stopped

  frontend:
    build: ./frontend
    ports:
      - "${FRONTEND_PORT:-5173}:5173"
    environment:
      - VITE_API_URL=${VITE_API_URL}
    depends_on:
      - backend
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

## Environment Template (`.env.example`)
This template shows the required variables. The `DATABASE_URL` correctly points to the internal Docker service name `db`.

```env
# Database
DATABASE_URL=postgresql://user:password@db:5432/myapp_db

# Ports
BACKEND_PORT=8000
FRONTEND_PORT=5173

# API Configuration
VITE_API_URL=http://localhost:8000
```

## Usage

### Quick Start
```bash
# Make the deployment script executable
chmod +x deploy.sh

# Run it
./deploy.sh
```

## Summary
This improved workflow achieves:
- ✅ **Robust Configuration** using `.env` files.
- ✅ **Simplified Template** with no modification scripts.
- ✅ **30-second deployment** target.
- ✅ **Zero network cloning** per project.
- ✅ **Consistent project structure**.
- ✅ **Automated Git repository creation** and push.
- ✅ **One-command Docker Compose deployment**.
