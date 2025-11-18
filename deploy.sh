#!/bin/bash
# Setup script for FastAPI + Svelte projects
# Run this after cloning the template to configure a new project
set -e

# --- Get Project Details ---
read -p "Enter new repository name: " REPO_NAME
read -p "Enter GitHub username: " GITHUB_USERNAME
read -p "Enter backend port (default 8000): " BACKEND_PORT
read -p "Enter frontend port (default 5173): " FRONTEND_PORT

# Set defaults if input is empty
BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

echo ""
echo "🚀 Setting up project: $REPO_NAME"
echo "📡 Backend port: $BACKEND_PORT"
echo "🌐 Frontend port: $FRONTEND_PORT"

# --- Environment Configuration ---
echo "🔧 Generating .env file..."
cat > .env <<EOL
# Project environment variables
DATABASE_URL=postgresql://postgres:1122@db:5432/${REPO_NAME}_db
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
VITE_API_URL=http://localhost:${BACKEND_PORT}
EOL

echo "✅ .env created"

# --- Git Setup ---
echo "📦 Updating Git remote..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
git branch -M main

# Create development branch
git checkout -b development

echo ""
echo "✅ Setup complete!"
echo "--------------------------------------------------"
echo "Next steps:"
echo "  1. Push to GitHub:"
echo "     git push -u origin main"
echo "     git push -u origin development"
echo ""
echo "  2. Start development (on development branch):"
echo "     ./dev.sh"
echo ""
echo "  3. Access:"
echo "     Frontend: http://localhost:$FRONTEND_PORT"
echo "     Backend: http://localhost:$BACKEND_PORT"
echo "--------------------------------------------------"
