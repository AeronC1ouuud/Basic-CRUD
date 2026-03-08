# Basic CRUD — Laravel + Vue + Docker

A simple Item CRUD application built with:
- **Backend**: Laravel 11 (REST API, PHP-FPM)
- **Frontend**: Vue 3 + Vite (SPA)
- **Database**: MySQL 8
- **Web server**: Nginx (serves both Laravel and the compiled Vue app)
- **Edge proxy**: Traefik v3 (routes traffic, dashboard included)

## Architecture

```
Browser
  │
  ▼
Traefik :80  ──── /api/*  ──▶  Nginx (crud_nginx)  ──▶  PHP-FPM (crud_php)  ──▶  MySQL (crud_db)
  │
  └──────────── /*      ──▶  Frontend Nginx (crud_frontend)
```

All services communicate over the `crud_network` Docker bridge network.

## Quick Start

### Prerequisites
- Docker >= 24
- Docker Compose v2
- `make` (optional, for convenience)

### 1. Build and start

```bash
make up
# or
docker compose up -d --build
```

### 2. Generate Laravel app key & run migrations

```bash
make key
make migrate
# optional: seed 10 demo items
make seed
```

### 3. Open in browser

| URL | Description |
|-----|-------------|
| http://localhost | Vue frontend (CRUD UI) |
| http://localhost/api/items | Laravel REST API |
| http://localhost:8080 | Traefik dashboard |

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/items` | List all items |
| POST | `/api/items` | Create an item |
| GET | `/api/items/{id}` | Get an item |
| PUT | `/api/items/{id}` | Update an item |
| DELETE | `/api/items/{id}` | Delete an item |

### Item payload

```json
{
  "name": "Widget",
  "description": "A sample widget",
  "quantity": 10,
  "price": 9.99
}
```

## Project Structure

```
Basic-CRUD/
├── backend/               # Laravel 11 application
│   ├── app/Http/Controllers/ItemController.php
│   ├── app/Models/Item.php
│   ├── database/migrations/
│   ├── database/factories/ItemFactory.php
│   ├── database/seeders/DatabaseSeeder.php
│   ├── routes/api.php
│   └── .env.example
├── frontend/              # Vue 3 + Vite SPA
│   ├── src/views/ItemList.vue
│   ├── src/views/ItemForm.vue
│   ├── src/router/index.js
│   ├── src/App.vue
│   └── vite.config.js
├── docker/
│   ├── php/Dockerfile
│   ├── frontend/Dockerfile + nginx-frontend.conf
│   ├── nginx/conf.d/app.conf
│   └── traefik/traefik.yml
├── docker-compose.yml
├── Makefile
└── .env
```

## Useful Commands

```bash
make logs        # tail all container logs
make shell-php   # open shell in PHP container
make shell-db    # open MySQL shell
make down        # stop all containers
```
