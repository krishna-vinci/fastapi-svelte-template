# AI Agent Guidelines

This file contains technical context and strict operational rules for AI agents working on this repository.

## 1. Runtime Environment & Infrastructure
- **Docker Only**: The entire application stack (Frontend, Backend, Database) runs inside Docker containers.
- **Services**:
  - `backend`: FastAPI (Python 3.11)
  - `frontend`: SvelteKit (Node 20)
  - `db`: PostgreSQL 15

## 2. Configuration & Ports
- **Strict Rule**: **NEVER assume default ports** (e.g., 8000 or 5173).
- **Source of Truth**: You MUST read the `.env` file or `docker-compose.yml` environment variables to determine the active ports.
  - Backend Port: `BACKEND_PORT`
  - Frontend Port: `FRONTEND_PORT`

## 3. Networking & Connectivity
- **Internal Communication** (Container-to-Container):
  - The Frontend container talks to the Backend container via the Docker network using the hostname `backend`.
  - URL: `http://backend:8000` (This internal port is fixed in the Dockerfile/Compose config).
- **External Communication** (Host-to-Container / Testing):
  - Access services from the host machine using `localhost` and the mapped ports from `.env`.
  - URL: `http://localhost:${BACKEND_PORT}`

## 4. Testing Protocol
- **API Testing**:
  - Use `curl` to test endpoints.
  - **CRITICAL**: Ensure you use the port defined in `BACKEND_PORT` from the `.env` file.
  - Example: `curl http://localhost:8090/health` (if BACKEND_PORT=8090).
- **Internal Commands**:
  - To run commands inside a container (e.g., database migrations, package installation), use `docker exec`.
  - Example: `docker compose exec backend python scripts/migrate.py`

## 5. Frontend Guidelines (SvelteKit)
- **UI Framework**: **shadcn-svelte**
- **Component Usage**:
  - We leverage `shadcn-svelte` components.
  - **DIRECTIVE**: When adding or modifying UI components, you **MUST use the `shadcn-ui-svelte` MCP server** if available.
  - **Workflow**:
    1.  Use `shadcn-ui-svelte` -> `list_components` to check availability.
    2.  Use `shadcn-ui-svelte` -> `get_component` / `get_component_demo` to understand the component's structure and usage pattern before implementing.
  - **Do NOT** attempt to reverse-engineer or guess the implementation of standard components. Use the tools provided to ensure consistency.

## 6. Database
- **Connection**: The application connects to the `db` service.
- **Credentials**: Defined in `.env` (`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`).
