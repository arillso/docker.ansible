# Set PROJECT_DIR to the CI-provided project directory if available; otherwise fallback to the current directory.
ifndef CI_PROJECT_DIR
	ifndef GITHUB_WORKSPACE
		PROJECT_DIR := $(shell pwd)
	else
		PROJECT_DIR := $(GITHUB_WORKSPACE)
	endif
else
	PROJECT_DIR := $(CI_PROJECT_DIR)
endif

.DEFAULT_GOAL := help

.PHONY: format-code format-all run-megalinter ansible-build tests help

format-code: ## Format code files using Prettier via Docker.
	@docker run --rm --name prettier -v $(PROJECT_DIR):$(PROJECT_DIR) -w /$(PROJECT_DIR) node:alpine npx prettier . --write

format-all: format-code ## Run both format-code and format-eclint.
	@echo "Formatting completed."

run-megalinter: ## Run Megalinter locally.
	@docker run --rm --name megalint -v $(PROJECT_DIR):/tmp/lint busybox rm -rf /tmp/lint/megalinter-reports
	@docker run --rm --name megalint -v $(PROJECT_DIR):/tmp/lint oxsecurity/megalinter:v8.4.2

ansible-build: ## Build the Ansible Docker image.
	@docker build \
		--build-arg BUILD_DATE=$$(date -I) \
		--build-arg ANSIBLE_VERSION=$$(grep '^ansible-core==' requirements.txt | cut -d'=' -f3) \
		-t ansible:latest \
		-f Dockerfile .

tests: ansible-build ## Run Container Structure Tests.
	@docker run --rm \
		-v "$(PROJECT_DIR)/tests/structure-test.yml":/structure-test.yml \
		-v /var/run/docker.sock:/var/run/docker.sock \
		gcr.io/gcp-runtimes/container-structure-test:latest \
		test --image=ansible:latest --config=/structure-test.yml

help: ## Show an overview of available targets.
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
