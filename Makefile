.PHONY: build-docs-development
build-docs-development: ## Build the development docker image.
	docker compose --progress=plain -f docker/development/docs-compose.yaml build

.PHONY: start-docs-development
start-docs-development: ## Start the development docker container.
	docker compose -f docker/development/docs-compose.yaml up -d

.PHONY: stop-docs-development
stop-docs-development: ## Stop the development docker container.
	docker compose -f docker/development/docs-compose.yaml down

.PHONY: build-web-development
build-web-development: ## Build the development docker image.
	docker compose --progress=plain -f docker/development/web-compose.yaml build

.PHONY: start-web-development
start-web-development: ## Start the development docker container.
	docker compose -f docker/development/web-compose.yaml up -d

.PHONY: stop-web-development
stop-web-development: ## Stop the development docker container.
	docker compose -f docker/development/web-compose.yaml down

#.PHONY: build-staging
#build-staging: ## Build the staging docker image.
#	docker compose -f docker/staging/compose.yaml build
#
#.PHONY: start-staging
#start-staging: ## Start the staging docker container.
#	docker compose -f docker/staging/compose.yaml up -d
#
#.PHONY: stop-staging
#stop-staging: ## Stop the staging docker container.
#	docker compose -f docker/staging/compose.yaml down
#
#.PHONY: build-production
#build-production: ## Build the production docker image.
#	docker compose -f docker/production/compose.yaml build
#
#.PHONY: start-production
#start-production: ## Start the production docker container.
#	docker compose -f docker/production/compose.yaml up -d
#
#.PHONY: stop-production

#stop-production: ## Stop the production docker container.
#	docker compose -f docker/production/compose.yaml down