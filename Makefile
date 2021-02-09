APP_NAME="dariopad/github-agent-php"

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the image
	docker build -t $(APP_NAME) docker

test: ## Test the image
	docker build -t github-agent-test -f docker/Dockerfile.test docker

shell: ## Creates a shell inside the container for debug purposes
	docker run -it $(APP_NAME) bash

shell-compose: ## Creates a shell inside the docker-compose service for debug purposes
	docker-compose run --rm runner bash
