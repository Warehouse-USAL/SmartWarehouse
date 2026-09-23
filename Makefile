.PHONY: setup generate analyze test clean dev pr-checks e2e e2e-android e2e-ios build-web-image up-prod deploy logs help

# E2E (Patrol) — overridable: make e2e API_BASE_URL=http://192.168.0.10:8080
API_BASE_URL ?=
E2E_EMAIL ?= admin@smartwarehouse.local
E2E_PASSWORD ?= changeme
E2E_DEFINES = --dart-define=E2E_EMAIL=$(E2E_EMAIL) --dart-define=E2E_PASSWORD=$(E2E_PASSWORD) --dart-define=SPLASH_MS=0
ifneq ($(API_BASE_URL),)
E2E_DEFINES += --dart-define=API_BASE_URL=$(API_BASE_URL)
endif

.DEFAULT_GOAL := help

setup: ## Install dependencies across all packages
	dart pub global activate melos 6.3.3
	melos bootstrap

generate: ## Run code generation across all packages that use build_runner
	melos run --no-select generate

analyze: ## Run static analysis across all packages
	melos exec -- flutter analyze

test: ## Run tests across all packages
	melos run --no-select test

clean: ## Clean build artifacts across all packages
	melos exec -- flutter clean

dev: ## Start the Flutter web dev server with hot reload
	flutter run -d chrome

# ─── Preview web en el server (ver docs/superpowers/specs/2026-09-23-mobile-web-preview-deploy-design.md)

build-web-image: ## Build web con base /mobile/app/ y la imagen nginx local (sw-mobile:local)
	flutter build web --release --base-href /mobile/app/
	docker build -t sw-mobile:local --build-arg APP_VERSION=local .
	@echo "Probar con: docker run --rm -p 8090:80 sw-mobile:local  ->  http://localhost:8090/"

up-prod: ## Start the nginx container (served under /mobile behind the proxy)
	docker compose -f docker-compose.prod.yml up -d
	@echo "Mobile web started (container mobile:80)"

deploy: ## Pull the newest image and restart
	docker compose -f docker-compose.prod.yml pull
	docker compose -f docker-compose.prod.yml up -d
	@echo "Mobile web redeployed"

logs: ## Follow the mobile web container logs
	docker compose -f docker-compose.prod.yml logs -f mobile

pr-checks: analyze test ## Run the same checks CI would run on a PR

e2e: ## Run Patrol e2e tests on the default connected device (backend must be running)
	patrol test $(E2E_DEFINES)

e2e-android: ## Run Patrol e2e tests on the first Android emulator
	patrol test $(E2E_DEFINES) -d emulator

e2e-ios: ## Run Patrol e2e tests on an iOS simulator
	patrol test $(E2E_DEFINES) -d iPhone

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
