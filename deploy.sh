#!/bin/bash
# Setup script for FastAPI + Svelte projects
# Run this after cloning the template to configure a new project
set -e

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ This script must be run inside a Git repository."
  exit 1
fi

# --- Get Project Details ---
read -p "Enter new repository name: " REPO_NAME
read -p "Enter GitHub username: " GITHUB_USERNAME
read -p "Enter database user (default postgres): " DB_USER
read -p "Enter database password (default 1122): " DB_PASSWORD
read -p "Enter database name (default \${REPO_NAME}_db): " DB_NAME
read -p "Enter backend port (default 8000): " BACKEND_PORT
read -p "Enter frontend port (default 5173): " FRONTEND_PORT

# Set defaults if input is empty
# Sanitize REPO_NAME for default DB_NAME (lowercase, replace non-alphanumeric with _)
SAFE_DB_NAME=$(echo "${REPO_NAME}_db" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/_/g')

DB_USER=${DB_USER:-postgres}
DB_PASSWORD=${DB_PASSWORD:-1122}
DB_NAME=${DB_NAME:-$SAFE_DB_NAME}
BACKEND_PORT=${BACKEND_PORT:-8000}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

echo ""
echo "🚀 Setting up project: $REPO_NAME"
echo "🗄️  Database user: $DB_USER"
echo "🗄️  Database name: $DB_NAME"
echo "📡 Backend port: $BACKEND_PORT"
echo "🌐 Frontend port: $FRONTEND_PORT"

# --- Environment Configuration ---
echo "🔧 Generating .env file..."
cat > .env <<EOL
# Project environment variables
PROJECT_NAME=${REPO_NAME}

# Database Configuration
POSTGRES_USER=${DB_USER}
POSTGRES_PASSWORD=${DB_PASSWORD}
POSTGRES_DB=${DB_NAME}

# Database Connection String
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}

BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}
VITE_API_URL=http://localhost:${BACKEND_PORT}

# Server-side internal API URL
API_BASE_URL=http://backend:8000

# CORS Configuration
CORS_ORIGINS=http://localhost:${FRONTEND_PORT},http://localhost:${BACKEND_PORT}

# Public URL
PUBLIC_URL=http://localhost:${FRONTEND_PORT}
EOL

echo "✅ .env created"

# --- Git Branch Preparation ---
echo "📦 Preparing Git branches..."
git checkout main >/dev/null 2>&1 || git checkout -b main >/dev/null 2>&1
git branch -M main
git checkout -B development >/dev/null 2>&1
git checkout main >/dev/null 2>&1

# --- Remote & Repository Setup ---
git remote remove origin 2>/dev/null || true

REMOTE_SET=false
GH_USED=false
PUSHED_MAIN=false
PUSHED_DEV=false
SSH_AVAILABLE=false

if command -v gh >/dev/null 2>&1; then
  read -p "Create GitHub repo as private? (Y/n): " PRIVATE_CHOICE
  if [[ "$PRIVATE_CHOICE" =~ ^[Nn]$ ]]; then
    VISIBILITY_FLAG="--public"
    echo "🔓 Repository will be public."
  else
    VISIBILITY_FLAG="--private"
    echo "🔒 Repository will be private."
  fi

  echo "🌐 Creating GitHub repository via gh..."
  if gh repo create "${GITHUB_USERNAME}/${REPO_NAME}" ${VISIBILITY_FLAG} \
      --source=. --remote=origin --push; then
    REMOTE_SET=true
    GH_USED=true
    PUSHED_MAIN=true
    echo "✅ GitHub repository created and main branch pushed."
  else
    echo "⚠️ gh repo create failed. Falling back to manual remote setup."
  fi
else
  echo "⚠️ GitHub CLI (gh) not found. Falling back to manual remote setup."
fi

if [ "$REMOTE_SET" = false ]; then
  echo "📎 Configuring remote manually..."
  SSH_CHECK=$(ssh -T git@github.com 2>&1 || true)
  if echo "$SSH_CHECK" | grep -qi "successfully authenticated"; then
    SSH_AVAILABLE=true
    GIT_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
    echo "🔑 SSH access detected. Using SSH remote."
  else
    SSH_AVAILABLE=false
    GIT_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    echo "ℹ️  SSH access not detected. Using HTTPS remote."
  fi
  git remote add origin "$GIT_URL"
  REMOTE_SET=true
fi

# Ensure development branch exists and finish on it
git checkout -B development >/dev/null 2>&1
git checkout main >/dev/null 2>&1

if [ "$GH_USED" = true ]; then
  git checkout development >/dev/null 2>&1
  echo "📤 Pushing development branch..."
  git push -u origin development
  PUSHED_DEV=true
elif [ "$SSH_AVAILABLE" = true ]; then
  git checkout development >/dev/null 2>&1
  echo "🔁 Push branches to GitHub now via SSH? (y/n)"
  read -p "Push now? " PUSH_NOW
  if [[ "$PUSH_NOW" =~ ^[Yy]$ ]]; then
    git checkout main >/dev/null 2>&1
    git push -u origin main
    git checkout development >/dev/null 2>&1
    git push -u origin development
    PUSHED_MAIN=true
    PUSHED_DEV=true
    echo "✅ Branches pushed successfully."
  else
    echo "⏭️  Skipping push for now."
  fi
else
  git checkout development >/dev/null 2>&1
fi

# --- Final Instructions ---
echo ""
echo "✅ Setup complete!"
echo "--------------------------------------------------"
if [ "$PUSHED_MAIN" = false ] || [ "$PUSHED_DEV" = false ]; then
  echo "🔔 Remember to push when ready:"
  echo "     git push -u origin main"
  echo "     git push -u origin development"
  echo ""
fi
echo "Next steps:"
echo "  1. Start development (you are on 'development' branch):"
echo "     ./dev.sh"
echo ""
echo "  2. Access services:"
echo "     Frontend:  http://localhost:$FRONTEND_PORT"
echo "     Backend:   http://localhost:$BACKEND_PORT"
echo "     Health:    http://localhost:$BACKEND_PORT/health"
echo "--------------------------------------------------"
