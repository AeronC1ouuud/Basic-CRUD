.PHONY: up down build restart logs migrate seed key shell-php shell-db ps

DOCKER := sg docker -c

## Build and start all containers
up:
	$(DOCKER) "docker compose up -d --build"

## Stop all containers
down:
	$(DOCKER) "docker compose down"

## Rebuild images without cache
build:
	$(DOCKER) "docker compose build --no-cache"

## Restart all containers
restart:
	$(DOCKER) "docker compose restart"

## Tail logs (Ctrl-C to stop)
logs:
	$(DOCKER) "docker compose logs -f"

## Show container status
ps:
	$(DOCKER) "docker compose ps"

## Run Laravel migrations
migrate:
	$(DOCKER) "docker compose exec php php artisan migrate --force"

## Run migrations + seed demo data
seed:
	$(DOCKER) "docker compose exec php php artisan db:seed --force"

## Generate Laravel app key
key:
	$(DOCKER) "docker compose exec php php artisan key:generate"

## Open shell inside PHP container
shell-php:
	$(DOCKER) "docker compose exec php sh"

## Open MySQL shell
shell-db:
	$(DOCKER) "docker compose exec db mysql -ucrud_user -psecret crud_db"
