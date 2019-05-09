S3_BUCKET="lambda-coffee-terraform"
DYNAMODB_TABLE="lambda-coffee-terraform"

AWS_ACCESS_KEY_ID=$(shell aws configure get gracepoint.aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(shell aws configure get gracepoint.aws_secret_access_key)

TERRAFORM := AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	docker-compose run --rm terraform

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

.SHELL := /usr/bin/bash

.PHONY: help prep plan apply destroy destroy-target

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

prep: ## Configure terraform backend
	@$(TERRAFORM) init \
	-input=false \
	-force-copy \
	-backend-config="bucket=$(S3_BUCKET)" \
	-backend-config="dynamodb_table=$(DYNAMODB_TABLE)"

plan: prep ## Show what terraform thinks it will do
	@$(TERRAFORM) plan

apply: prep ## Have terraform apply changes
	@$(TERRAFORM) apply

destroy: prep ## Destroy resources
	@$(TERRAFORM) destroy

destroy-target: prep ## Destroy a specific resource. Caution though, this destroys chained resources.
	@echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy target: " DATA && \
		$(TERRAFORM) destroy -target=$$DATA
