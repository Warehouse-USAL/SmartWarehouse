.PHONY: setup generate analyze test clean dev pr-checks help

.DEFAULT_GOAL := help

setup: ## Install dependencies across all packages
	dart pub global activate melos
	melos bootstrap

generate: ## Run code generation across all packages that use build_runner
	melos run generate

analyze: ## Run static analysis across all packages
	melos exec -- flutter analyze

test: ## Run tests across all packages
	melos run test

clean: ## Clean build artifacts across all packages
	melos exec -- flutter clean

dev: ## Start the Flutter web dev server with hot reload
	flutter run -d chrome

pr-checks: analyze test ## Run the same checks CI would run on a PR

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
