S3_BUCKET="lambda-coffee-terraform"
DYNAMODB_TABLE="lambda-coffee-terraform"

AWS_ACCESS_KEY_ID=$(shell aws configure get gracepoint.aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(shell aws configure get gracepoint.aws_secret_access_key)

TERRAFORM := AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	docker-compose run --rm terraform

VARS="$(ENV).tfvars"
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

.SHELL := /usr/bin/bash

.PHONY: help set-env prep plan apply destroy destroy-target

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(ENV) ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -f "$(VARS)" ]; then \
		echo "$(BOLD)$(RED)Could not find variables file: $(VARS)$(RESET)"; \
		exit 1; \
	fi

prep: set-env ## Prepare a new workspace (environment) if needed
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@$(TERRAFORM) init \
		-input=false \
		-force-copy \
		-backend-config="bucket=$(S3_BUCKET)" \
		-backend-config="dynamodb_table=$(DYNAMODB_TABLE)"
	@echo "$(BOLD)Switching to environment workspace $(ENV)$(RESET)"
	@$(TERRAFORM) workspace select $(ENV) || $(TERRAFORM) workspace new $(ENV)

plan: prep ## Show what terraform thinks it will do
	@$(TERRAFORM) plan -var-file="$(VARS)"

apply: prep ## Have terraform apply changes
	@$(TERRAFORM) apply -var-file="$(VARS)"

destroy: prep ## Destroy resources
	@$(TERRAFORM) destroy -var-file="$(VARS)"

destroy-target: prep ## Destroy a specific resource. Caution though, this destroys chained resources.
	@echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy target: " DATA && \
		$(TERRAFORM) destroy -var-file=$(VARS) -target=$$DATA
