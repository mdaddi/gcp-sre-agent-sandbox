# GCP SRE Agent Sandbox - C4 Architecture Diagrams

## Level 1: System Context Diagram

```mermaid
C4Context
    title System Context - GCP SRE Agent Sandbox

    Person(sre, "SRE Engineer", "Diagnoses and remediates<br/>application issues")
    Person(dev, "Developer", "Deploys infrastructure<br/>and applications")

    System(srelab, "GCP SRE Agent Sandbox", "GKE-based e-commerce demo<br/>with breakable scenarios<br/>for SRE training")

    System_Ext(gemini, "Gemini in Cloud Logging", "AI-powered log analysis<br/>and diagnosis")
    System_Ext(ghcr, "GitHub Container Registry", "ghcr.io/azure-samples/<br/>aks-store-demo images")
    System_Ext(gcp_iam, "Google Cloud IAM", "Identity and access<br/>management")

    Rel(sre, srelab, "Diagnoses failures,<br/>applies scenarios", "kubectl, gcloud")
    Rel(dev, srelab, "Deploys & manages<br/>infrastructure", "Terraform, bash scripts")
    Rel(sre, gemini, "Queries logs with<br/>natural language")
    Rel(srelab, ghcr, "Pulls container images")
    Rel(srelab, gcp_iam, "Authenticates via<br/>Workload Identity")
```

## Level 2: Container Diagram

```mermaid
C4Container
    title Container Diagram - GCP SRE Agent Sandbox

    Person(sre, "SRE Engineer")
    Person(dev, "Developer")

    System_Boundary(gcp, "Google Cloud Platform") {

        System_Boundary(gke, "GKE Cluster (srelab-gke)") {

            System_Boundary(pets_ns, "Namespace: pets") {
                Container(storefront, "store-front", "Vue.js", "Customer-facing<br/>web UI :8080")
                Container(storeadmin, "store-admin", "Vue.js", "Admin panel :8081")
                Container(orderservice, "order-service", "Node.js", "Order processing :3000")
                Container(productservice, "product-service", "Rust", "Product catalog :3002")
                Container(makelineservice, "makeline-service", "Go", "Order fulfillment :3001")
                Container(virtualcustomer, "virtual-customer", "Load Gen", "Simulates traffic")
                ContainerDb(mongodb, "MongoDB", "MongoDB 4.4", "Order database<br/>PD: standard-rwo")
                Container(rabbitmq, "RabbitMQ", "RabbitMQ 3.11", "Message queue<br/>AMQP :5672")
                Container(grafana, "Grafana", "Grafana 10.0", "Dashboards :3000<br/>LB :80")
            }

            Container(gmp, "GMP PodMonitoring", "CRDs", "Metrics scraping<br/>30s interval")
        }

        System_Boundary(infra, "GCP Managed Services") {
            ContainerDb(secretmgr, "Secret Manager", "GCP", "mongodb-password<br/>rabbitmq-password")
            Container(cloudlogging, "Cloud Logging", "GCP", "k8s_container &<br/>k8s_pod logs")
            ContainerDb(bigquery, "BigQuery", "GCP", "Log sink dataset<br/>90-day retention")
            Container(cloudmon, "Cloud Monitoring", "GCP", "Alert policies<br/>& dashboards")
            Container(artifactreg, "Artifact Registry", "GCP", "Docker repo:<br/>srelab-docker")
            Container(pubsub, "Pub/Sub", "GCP", "Alert notifications")
        }

        System_Boundary(network, "VPC: srelab-network") {
            Container(subnet_pods, "Subnet: pods", "10.0.0.0/22", "Pod networking")
            Container(subnet_svc, "Subnet: services", "10.0.4.0/24", "Service networking")
            Container(nat, "Cloud NAT", "Router", "Outbound internet")
        }
    }

    Rel(sre, storefront, "Browses store", "HTTP :80 LB")
    Rel(sre, grafana, "Views dashboards", "HTTP :80 LB")
    Rel(dev, gke, "Manages cluster", "kubectl, terraform")
    Rel(storefront, orderservice, "Places orders", "HTTP")
    Rel(storefront, productservice, "Lists products", "HTTP")
    Rel(storeadmin, productservice, "Manages products", "HTTP")
    Rel(storeadmin, makelineservice, "Views orders", "HTTP")
    Rel(orderservice, rabbitmq, "Publishes orders", "AMQP :5672")
    Rel(makelineservice, rabbitmq, "Consumes orders", "AMQP :5672")
    Rel(makelineservice, mongodb, "Stores orders", "TCP :27017")
    Rel(virtualcustomer, orderservice, "Generates load", "HTTP")
    Rel(cloudlogging, bigquery, "Sinks logs", "Log Router")
    Rel(cloudmon, pubsub, "Fires alerts", "Notification Channel")
    Rel(grafana, cloudmon, "Queries metrics", "Stackdriver API")
    Rel(gmp, cloudmon, "Exports metrics", "GMP pipeline")
```

## Level 3: Component Diagram (Infrastructure as Code)

```mermaid
C4Component
    title Component Diagram - Terraform Modules

    Person(dev, "Developer")

    System_Boundary(terraform, "infra/terraform/") {

        Component(main, "main.tf", "Root Module", "Orchestrates all modules,<br/>configures providers")
        Component(variables, "variables.tf", "Variables", "gcp_project_id, gcp_region,<br/>workload_name, passwords")
        Component(outputs, "outputs.tf", "Outputs", "cluster_endpoint, registry_url,<br/>dashboard_ids")

        System_Boundary(modules, "modules/") {
            Component(mod_vpc, "vpc/", "Network Module", "VPC, subnets, firewall,<br/>Cloud NAT, router")
            Component(mod_gke, "gke/", "GKE Module", "Cluster, node pools,<br/>StorageClasses (CSI)")
            Component(mod_ar, "artifact-registry/", "Registry Module", "Docker repo,<br/>IAM reader/writer")
            Component(mod_sm, "secret-manager/", "Secrets Module", "Secrets + versions,<br/>accessor bindings")
            Component(mod_log, "logging/", "Logging Module", "BigQuery dataset,<br/>log sink, exclusions")
            Component(mod_mon, "monitoring/", "Monitoring Module", "Dashboard, alerts,<br/>Pub/Sub, webhook")
            Component(mod_iam, "iam/", "IAM Module", "Service accounts,<br/>Workload Identity bindings")
        }
    }

    Rel(dev, main, "terraform apply", "CLI")
    Rel(main, mod_vpc, "network_name, CIDRs, region")
    Rel(main, mod_gke, "project_id, cluster_name,<br/>vpc outputs, k8s version")
    Rel(main, mod_ar, "project_id, region,<br/>gke SA email")
    Rel(main, mod_sm, "project_id, secrets map,<br/>gke SA email")
    Rel(main, mod_log, "project_id, region,<br/>sink_name, dataset")
    Rel(main, mod_mon, "project_id, region,<br/>cluster_name, webhook_url")
    Rel(main, mod_iam, "project_id, cluster_name,<br/>WI pool, SA configs")
    Rel(mod_gke, mod_vpc, "depends_on", "network_name,<br/>subnet_name")
    Rel(mod_iam, mod_gke, "depends_on", "cluster outputs")
    Rel(mod_iam, mod_sm, "depends_on", "secret access")
```

## Level 4: Deployment Diagram

```mermaid
C4Deployment
    title Deployment Diagram - GKE Node Pools

    Deployment_Node(gcp, "Google Cloud Platform", "us-central1") {

        Deployment_Node(gke, "GKE Cluster: srelab-gke", "Kubernetes 1.32, VPC-native") {

            Deployment_Node(system_pool, "System Node Pool", "2x n2-standard-2, 50GB pd-standard") {
                Container(kube_system, "kube-system", "K8s", "CoreDNS, kube-proxy,<br/>Calico, GMP collector")
            }

            Deployment_Node(user_pool, "User Node Pool", "3x n2-standard-2, 100GB pd-standard") {
                Container(app_pods, "Application Pods", "pets namespace", "store-front (2)<br/>store-admin (1)<br/>order-service (2)<br/>product-service (2)<br/>makeline-service (2)<br/>virtual-customer (1)")
                Container(data_pods, "Data Pods", "pets namespace", "mongodb (1) + PVC 8Gi<br/>rabbitmq (1)")
                Container(obs_pods, "Observability Pods", "pets namespace", "grafana (1)")
            }
        }

        Deployment_Node(managed, "GCP Managed Services") {
            Container(svc_mon, "Cloud Monitoring", "", "2 alert policies<br/>1 dashboard")
            Container(svc_log, "Cloud Logging", "", "Log sink to BigQuery<br/>90-day retention")
            Container(svc_ar, "Artifact Registry", "", "srelab-docker repo")
            Container(svc_sm, "Secret Manager", "", "2 secrets (auto-replicated)")
            Container(svc_ps, "Pub/Sub", "", "srelab-metrics-alerts topic")
        }
    }
```

## Network Topology

```
+------------------------------------------------------------------+
|  VPC: srelab-network                                             |
|                                                                  |
|  +---------------------------+  +---------------------------+    |
|  | Subnet: pods              |  | Subnet: services          |    |
|  | 10.0.0.0/22               |  | 10.0.4.0/24               |    |
|  |                           |  |                           |    |
|  | Secondary ranges:         |  | Flow logs: enabled        |    |
|  |   pods:     10.1.0.0/16   |  +---------------------------+    |
|  |   services: 10.2.0.0/16   |                                  |
|  |                           |                                  |
|  | Flow logs: enabled        |                                  |
|  +---------------------------+                                  |
|                                                                  |
|  Firewall Rules:                                                 |
|  +---------------------------+  +---------------------------+    |
|  | allow-internal (pri:1000) |  | allow-ssh (pri:1001)      |    |
|  | TCP/UDP 0-65535           |  | TCP 22                    |    |
|  | src: pod + svc CIDRs      |  | src: 0.0.0.0/0            |    |
|  +---------------------------+  +---------------------------+    |
|                                                                  |
|  Cloud NAT: srelab-network-nat (AUTO_ONLY, all subnets)          |
|  Cloud Router: srelab-network-router                             |
+------------------------------------------------------------------+
         |                    |                    |
    [LoadBalancer]       [LoadBalancer]       [LoadBalancer]
    store-front:80       store-admin:80       grafana:80
```
