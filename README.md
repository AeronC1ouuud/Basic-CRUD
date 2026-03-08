# Basic CRUD — Laravel + Vue + Docker

A simple Item CRUD application built with:
- **Backend**: Laravel 11 (REST API, PHP 8.2 FPM)
- **Frontend**: Vue 3 + Vite (SPA)
- **Database**: MySQL 8
- **Web server**: Nginx (serves Laravel via PHP-FPM, and the compiled Vue app)
- **Edge proxy**: Traefik v3 (host-based routing, dashboard included)

## Architecture

```
Browser
  │
  ▼
Traefik :80
  ├── app.localhost  ──▶  Frontend Nginx (crud_frontend)
  └── api.localhost  ──▶  Backend Nginx (crud_nginx) ──▶ PHP-FPM (crud_php) ──▶ MySQL (crud_db)
```

All services communicate over the `crud_network` Docker bridge network.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) >= 24
- [Docker Compose](https://docs.docker.com/compose/install/) v2 (included with Docker Desktop)
- `make` (optional, for convenience commands)
- Ports **80** and **8080** available on your machine

## Setup

### 1. Clone the repository

```bash
git clone <repo-url> Basic-CRUD
cd Basic-CRUD
```

### 2. Configure environment variables

Default env files are provided and work out of the box for local development:

- `env/db.env` — MySQL credentials
- `env/php.env` — Laravel / PHP-FPM settings
- `.env` — root-level Docker Compose env

To customise, edit these files before starting. The defaults are:

| Variable           | Default        | File          |
|--------------------|----------------|---------------|
| `MYSQL_DATABASE`   | `crud_db`      | `env/db.env`  |
| `MYSQL_USER`       | `crud_user`    | `env/db.env`  |
| `MYSQL_PASSWORD`   | `secret`       | `env/db.env`  |
| `DB_HOST`          | `db`           | `env/php.env` |
| `DB_PORT`          | `3306`         | `env/php.env` |

> **Note**: If you change database credentials in `env/db.env`, update `env/php.env` to match.

### 3. Configure local DNS (hosts file)

Traefik routes traffic based on hostname. Add these entries to your hosts file:

**Linux / macOS** — edit `/etc/hosts`:
```
127.0.0.1  app.localhost
127.0.0.1  api.localhost
127.0.0.1  crud.test
```

**Windows (WSL users must edit the Windows hosts file)** — edit `C:\Windows\System32\drivers\etc\hosts` as Administrator:
```
127.0.0.1  app.localhost
127.0.0.1  api.localhost
127.0.0.1  crud.test
```

> On most modern browsers, `*.localhost` resolves to `127.0.0.1` automatically, so those entries may be optional. The `crud.test` entry is always required.

### 4. Build and start

```bash
make up
# or without make:
docker compose up -d --build
```

On first start, the PHP entrypoint will automatically:
- Install Composer dependencies (if `vendor/` is missing)
- Copy `.env.example` → `.env` (if not present)
- Inject database credentials from environment variables
- Generate a Laravel app key
- Wait for MySQL and run migrations

### 5. (Optional) Seed demo data

```bash
make seed
# or:
docker compose exec php php artisan db:seed --force
```

This inserts 10 sample items into the database.

### 6. Open in browser

| URL                            | Description            |
|--------------------------------|------------------------|
| http://app.localhost           | Vue frontend (CRUD UI)       |
| http://crud.test               | Vue frontend (alternate URL) |
| http://api.localhost/api/items | Laravel REST API             |
| http://localhost:8080          | Traefik dashboard            |

## API Reference

| Method | Endpoint           | Description      |
|--------|--------------------|------------------|
| GET    | `/api/items`       | List all items   |
| POST   | `/api/items`       | Create an item   |
| GET    | `/api/items/{id}`  | Get an item      |
| PUT    | `/api/items/{id}`  | Update an item   |
| DELETE | `/api/items/{id}`  | Delete an item   |

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
├── backend/                        # Laravel 11 application
│   ├── app/Http/Controllers/ItemController.php
│   ├── app/Models/Item.php
│   ├── database/migrations/
│   ├── database/factories/ItemFactory.php
│   ├── database/seeders/DatabaseSeeder.php
│   ├── routes/api.php
│   └── .env.example
├── frontend/                       # Vue 3 + Vite SPA
│   ├── src/views/ItemList.vue
│   ├── src/views/ItemForm.vue
│   ├── src/router/index.js
│   ├── src/App.vue
│   └── vite.config.js
├── docker/
│   ├── php/Dockerfile              # PHP 8.2 FPM + Composer
│   ├── php/entrypoint.sh           # Auto-setup on container start
│   ├── frontend/Dockerfile         # Multi-stage: Node build → Nginx
│   ├── frontend/nginx-frontend.conf
│   ├── nginx/conf.d/app.conf       # Backend Nginx config
│   └── traefik/
│       ├── traefik.yml             # Static Traefik config
│       └── dynamic.yml             # Host-based routing rules
├── env/
│   ├── db.env                      # MySQL env vars
│   └── php.env                     # Laravel env vars
├── docker-compose.yml
├── Makefile
└── .env
```

## Useful Commands

```bash
make up          # Build and start all containers
make down        # Stop and remove all containers
make build       # Rebuild images without cache
make restart     # Restart all containers
make logs        # Tail all container logs (Ctrl-C to stop)
make ps          # Show container status
make migrate     # Run Laravel migrations
make seed        # Seed demo data
make key         # Generate Laravel app key
make shell-php   # Open shell in PHP container
make shell-db    # Open MySQL shell
```

## Troubleshooting

### Containers fail to start / port conflict

Make sure ports **80** and **8080** are not in use by another service:

```bash
sudo lsof -i :80
sudo lsof -i :8080
```

### "Connection refused" on app.localhost

- Verify your `/etc/hosts` has the entries from step 3.
- Check that Traefik is running: `docker compose ps traefik`.

### Database connection errors

- Ensure the MySQL container is healthy: `docker compose ps db`.
- Verify credentials match between `env/db.env` and `env/php.env`.
- Check PHP container logs: `docker compose logs php`.

### Frontend shows blank page

- Confirm the frontend container built successfully: `docker compose logs frontend`.
- Make sure you're visiting `http://app.localhost`, not `http://localhost`.

### Resetting everything

```bash
make down
docker volume rm basic-crud_db_data basic-crud_php_vendor basic-crud_backend_storage
make up
```
