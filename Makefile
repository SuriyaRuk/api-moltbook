# =============================================================================
# Moltbook API - Makefile
# =============================================================================

.PHONY: help build up down restart logs ps shell db-shell redis-shell \
        dev prod clean prune migrate health

# Default target
help:
	@echo ""
	@echo "  Moltbook API - Docker Commands"
	@echo "  ────────────────────────────────────────"
	@echo "  make build    Build Docker images"
	@echo "  make up       Start all services (production)"
	@echo "  make dev      Start all services (development)"
	@echo "  make down     Stop all services"
	@echo "  make restart  Restart all services"
	@echo "  make logs     Tail logs from all services"
	@echo "  make ps       Show running services"
	@echo "  make shell    Open shell in API container"
	@echo "  make db-shell Open psql in PostgreSQL container"
	@echo "  make redis-shell Open redis-cli in Redis container"
	@echo "  make migrate  Run database schema"
	@echo "  make health   Check API health endpoint"
	@echo "  make clean    Remove containers and volumes"
	@echo "  make prune    Remove all unused Docker resources"
	@echo ""

# Build images
build:
	docker compose build --no-cache

# Start production
up:
	docker compose up -d

# Start development
dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Stop services
down:
	docker compose down

# Restart services
restart:
	docker compose restart

# Show logs
logs:
	docker compose logs -f

# Show services status
ps:
	docker compose ps

# Shell into API container
shell:
	docker exec -it moltbook-api sh

# Shell into PostgreSQL
db-shell:
	docker exec -it moltbook-postgres psql -U $${POSTGRES_USER:-moltbook} -d $${POSTGRES_DB:-moltbook}

# Shell into Redis
redis-shell:
	docker exec -it moltbook-redis redis-cli

# Run database schema
migrate:
	docker exec -i moltbook-postgres psql -U $${POSTGRES_USER:-moltbook} -d $${POSTGRES_DB:-moltbook} < scripts/schema.sql

# Check health
health:
	@curl -s http://localhost:$${PORT:-3000}/api/v1/health | python3 -m json.tool || echo "API not reachable"

# Clean containers and volumes
clean:
	docker compose down -v --remove-orphans

# Prune Docker system
prune:
	docker system prune -f
