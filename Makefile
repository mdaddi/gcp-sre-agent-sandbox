.PHONY: deploy destroy validate fix troubleshoot estimate-costs \
       break-oom break-crash break-image break-cpu break-pending \
       break-probe break-network break-config break-db break-service \
       tf-init tf-plan tf-apply watch-pods

WORKLOAD_NAME ?= srelab
GCP_REGION    ?= us-central1
SCRIPTS_DIR   := gcp-sre-agent/scripts
K8S_BASE      := gcp-sre-agent/k8s/base
K8S_SCENARIOS := gcp-sre-agent/k8s/scenarios
TF_DIR        := gcp-sre-agent/infra/terraform

## Deployment

deploy:
	bash $(SCRIPTS_DIR)/deploy.sh $(WORKLOAD_NAME) $(GCP_REGION)

destroy:
	bash $(SCRIPTS_DIR)/destroy.sh $(WORKLOAD_NAME)

validate:
	bash $(SCRIPTS_DIR)/validate-deployment.sh

troubleshoot:
	bash $(SCRIPTS_DIR)/troubleshoot.sh

estimate-costs:
	bash $(SCRIPTS_DIR)/estimate-costs.sh

## Terraform

tf-init:
	cd $(TF_DIR) && terraform init

tf-plan:
	cd $(TF_DIR) && terraform plan \
		-var="gcp_project_id=$(GCP_PROJECT_ID)" \
		-var="gcp_region=$(GCP_REGION)" \
		-var="workload_name=$(WORKLOAD_NAME)"

tf-apply:
	cd $(TF_DIR) && terraform apply \
		-var="gcp_project_id=$(GCP_PROJECT_ID)" \
		-var="gcp_region=$(GCP_REGION)" \
		-var="workload_name=$(WORKLOAD_NAME)"

## Breakable Scenarios

break-oom:
	kubectl apply -f $(K8S_SCENARIOS)/oom-killed.yaml

break-crash:
	kubectl apply -f $(K8S_SCENARIOS)/crash-loop.yaml

break-image:
	kubectl apply -f $(K8S_SCENARIOS)/image-pull-backoff.yaml

break-cpu:
	kubectl apply -f $(K8S_SCENARIOS)/high-cpu.yaml

break-pending:
	kubectl apply -f $(K8S_SCENARIOS)/pending-pods.yaml

break-probe:
	kubectl apply -f $(K8S_SCENARIOS)/probe-failure.yaml

break-network:
	kubectl apply -f $(K8S_SCENARIOS)/network-block.yaml

break-config:
	kubectl apply -f $(K8S_SCENARIOS)/missing-config.yaml

break-db:
	kubectl apply -f $(K8S_SCENARIOS)/mongodb-down.yaml

break-service:
	kubectl apply -f $(K8S_SCENARIOS)/service-mismatch.yaml

## Fix / Restore

fix:
	kubectl apply -f $(K8S_BASE)/application.yaml

## Monitoring

watch-pods:
	kubectl get pods -n cloudops -w
