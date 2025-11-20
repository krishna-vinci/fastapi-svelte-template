# FastAPI + SvelteKit + Docker Template

A robust, production-ready starter template for building modern full-stack web applications.

## Features
- **Backend**: FastAPI (Python 3.11) with async PostgreSQL support.
- **Frontend**: SvelteKit (Node 20) with **shadcn-svelte** for UI components.
- **Database**: PostgreSQL 15.
- **Infrastructure**: Fully Dockerized environment with Docker Compose.
- **Developer Experience**: 
  - Hot reloading for both frontend and backend.
  - Automated setup scripts.
  - Type-safe development.

## Quick Start

### 1. Setup
Run the deployment script to configure your environment (creates `.env`, sets up ports, and initializes git branches).
**Note**: Ensure you have the GitHub CLI (`gh`) installed and authenticated if you want to automatically create and push the repository to GitHub.

```bash
./deploy.sh
```

### 2. Development
Start the development environment:
```bash
./dev.sh
```

This will spin up the Docker containers. You can access your services at:
- **Frontend**: `http://localhost:<FRONTEND_PORT>` (default 5173)
- **Backend**: `http://localhost:<BACKEND_PORT>` (default 8000)
- **API Docs**: `http://localhost:<BACKEND_PORT>/docs`

## Architecture
- **Frontend Proxy**: The SvelteKit server (`hooks.server.ts`) proxies `/api` requests to the backend container, solving CORS issues for server-side calls.
- **CORS**: The FastAPI backend is configured to accept requests from the frontend's origin.

## Requirements
- Docker & Docker Compose
- Git
- GitHub CLI (`gh`) (Optional, for automated repo creation)
