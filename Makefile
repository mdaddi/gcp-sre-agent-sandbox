.PHONY: help deploy destroy validate fix troubleshoot estimate-costs \
       break-oom break-crash break-image break-cpu break-pending \
       break-probe break-network break-config break-db break-service \
       tf-init tf-plan tf-apply watch-pods

.DEFAULT_GOAL := help

help: ## Show this help
	@echo "GCP SRE Agent Sandbox"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

WORKLOAD_NAME ?= srelab
GCP_REGION    ?= us-central1
SCRIPTS_DIR   := gcp-sre-agent/scripts
K8S_BASE      := gcp-sre-agent/k8s/base
K8S_SCENARIOS := gcp-sre-agent/k8s/scenarios
TF_DIR        := gcp-sre-agent/infra/terraform

## Deployment

deploy: ## Deploy infrastructure and application
	bash $(SCRIPTS_DIR)/deploy.sh $(WORKLOAD_NAME) $(GCP_REGION)

destroy: ## Tear down all infrastructure
	bash $(SCRIPTS_DIR)/destroy.sh $(WORKLOAD_NAME)

validate: ## Validate deployment health
	bash $(SCRIPTS_DIR)/validate-deployment.sh

troubleshoot: ## Run troubleshooting diagnostics
	bash $(SCRIPTS_DIR)/troubleshoot.sh

estimate-costs: ## Show cost estimation breakdown
	bash $(SCRIPTS_DIR)/estimate-costs.sh

## Terraform

tf-init: ## Initialize Terraform
	cd $(TF_DIR) && terraform init

tf-plan: ## Preview Terraform changes
	cd $(TF_DIR) && terraform plan \
		-var="gcp_project_id=$(GCP_PROJECT_ID)" \
		-var="gcp_region=$(GCP_REGION)" \
		-var="workload_name=$(WORKLOAD_NAME)"

tf-apply: ## Apply Terraform changes
	cd $(TF_DIR) && terraform apply \
		-var="gcp_project_id=$(GCP_PROJECT_ID)" \
		-var="gcp_region=$(GCP_REGION)" \
		-var="workload_name=$(WORKLOAD_NAME)"

## Breakable Scenarios

break-oom: ## Inject OOMKilled failure
	kubectl apply -f $(K8S_SCENARIOS)/oom-killed.yaml

break-crash: ## Inject CrashLoopBackOff failure
	kubectl apply -f $(K8S_SCENARIOS)/crash-loop.yaml

break-image: ## Inject ImagePullBackOff failure
	kubectl apply -f $(K8S_SCENARIOS)/image-pull-backoff.yaml

break-cpu: ## Inject high CPU stress
	kubectl apply -f $(K8S_SCENARIOS)/high-cpu.yaml

break-pending: ## Inject pending pods (resource exhaustion)
	kubectl apply -f $(K8S_SCENARIOS)/pending-pods.yaml

break-probe: ## Inject health probe failure
	kubectl apply -f $(K8S_SCENARIOS)/probe-failure.yaml

break-network: ## Inject network policy block
	kubectl apply -f $(K8S_SCENARIOS)/network-block.yaml

break-config: ## Inject missing ConfigMap reference
	kubectl apply -f $(K8S_SCENARIOS)/missing-config.yaml

break-db: ## Inject MongoDB down (cascading failure)
	kubectl apply -f $(K8S_SCENARIOS)/mongodb-down.yaml

break-service: ## Inject service selector mismatch
	kubectl apply -f $(K8S_SCENARIOS)/service-mismatch.yaml

## Fix / Restore

fix: ## Restore healthy application state
	kubectl apply -f $(K8S_BASE)/application.yaml

## Monitoring

watch-pods: ## Watch pod status in cloudops namespace
	kubectl get pods -n cloudops -w
