# GCP SRE Agent Sandbox - Architecture Diagrams

## Level 1: System Context Diagram

```mermaid
graph TB
    sre(["SRE Engineer<br/>Diagnoses and remediates<br/>application issues"])
    dev(["Developer<br/>Deploys infrastructure<br/>and applications"])

    srelab["GCP SRE Agent Sandbox<br/>GKE-based e-commerce demo<br/>with breakable scenarios<br/>for SRE training"]

    gemini["Gemini in Cloud Logging<br/>AI-powered log analysis"]
    ghcr["GitHub Container Registry<br/>ghcr.io/gcp-sre-agent/<br/>store-demo images"]
    gcp_iam["Google Cloud IAM<br/>Identity and access management"]

    sre -- "Diagnoses failures,<br/>applies scenarios<br/>(kubectl, gcloud)" --> srelab
    dev -- "Deploys & manages<br/>infrastructure<br/>(Terraform, bash)" --> srelab
    sre -- "Queries logs with<br/>natural language" --> gemini
    srelab -- "Pulls container images" --> ghcr
    srelab -- "Authenticates via<br/>Workload Identity" --> gcp_iam

    style srelab fill:#438DD5,color:#fff
    style gemini fill:#999,color:#fff
    style ghcr fill:#999,color:#fff
    style gcp_iam fill:#999,color:#fff
```

## Level 2: Container Diagram

```mermaid
graph TB
    sre(["SRE Engineer"])
    dev(["Developer"])

    subgraph gcp ["Google Cloud Platform"]
        subgraph gke ["GKE Cluster - srelab-gke"]
            subgraph cloudops_ns ["Namespace: cloudops"]
                storefront["store-front<br/>Vue.js :8080"]
                storeadmin["store-admin<br/>Vue.js :8081"]
                orderservice["order-service<br/>Node.js :3000"]
                productservice["product-service<br/>Rust :3002"]
                makelineservice["makeline-service<br/>Go :3001"]
                virtualcustomer["virtual-customer<br/>Load Gen"]
                mongodb[("MongoDB 4.4<br/>Order database")]
                rabbitmq["RabbitMQ 3.11<br/>AMQP :5672"]
                grafana["Grafana 10.0<br/>Dashboards :80"]
            end
            gmp["GMP PodMonitoring<br/>Metrics scraping 30s"]
        end

        subgraph infra ["GCP Managed Services"]
            secretmgr[("Secret Manager<br/>mongodb-password<br/>rabbitmq-password")]
            cloudlogging["Cloud Logging<br/>k8s_container &<br/>k8s_pod logs"]
            bigquery[("BigQuery<br/>Log sink 90-day")]
            cloudmon["Cloud Monitoring<br/>Alerts & dashboards"]
            artifactreg["Artifact Registry<br/>srelab-docker"]
            pubsub["Pub/Sub<br/>Alert notifications"]
        end

        subgraph network ["VPC: srelab-network"]
            subnet_pods["Subnet: pods<br/>10.0.0.0/22"]
            subnet_svc["Subnet: services<br/>10.0.4.0/24"]
            nat["Cloud NAT<br/>Outbound internet"]
        end
    end

    sre -- "HTTP :80" --> storefront
    sre -- "HTTP :80" --> grafana
    dev -- "kubectl, terraform" --> gke
    storefront -- "HTTP" --> orderservice
    storefront -- "HTTP" --> productservice
    storeadmin -- "HTTP" --> productservice
    storeadmin -- "HTTP" --> makelineservice
    orderservice -- "AMQP :5672" --> rabbitmq
    makelineservice -- "AMQP :5672" --> rabbitmq
    makelineservice -- "TCP :27017" --> mongodb
    virtualcustomer -- "HTTP" --> orderservice
    cloudlogging -- "Log Router" --> bigquery
    cloudmon -- "Notification" --> pubsub
    grafana -- "Stackdriver API" --> cloudmon
    gmp -- "GMP pipeline" --> cloudmon

    style storefront fill:#438DD5,color:#fff
    style storeadmin fill:#438DD5,color:#fff
    style orderservice fill:#438DD5,color:#fff
    style productservice fill:#438DD5,color:#fff
    style makelineservice fill:#438DD5,color:#fff
    style virtualcustomer fill:#438DD5,color:#fff
    style grafana fill:#438DD5,color:#fff
    style gmp fill:#438DD5,color:#fff
```

## Level 3: Component Diagram - Terraform Modules

```mermaid
graph TB
    dev(["Developer"])

    subgraph terraform ["infra/terraform/"]
        main["main.tf<br/>Root Module"]
        variables["variables.tf<br/>gcp_project_id, gcp_region,<br/>workload_name, passwords"]
        outputs["outputs.tf<br/>cluster_endpoint, registry_url"]

        subgraph modules ["modules/"]
            mod_vpc["vpc/<br/>VPC, subnets, firewall,<br/>Cloud NAT, router"]
            mod_gke["gke/<br/>Cluster, node pools,<br/>StorageClasses"]
            mod_ar["artifact-registry/<br/>Docker repo,<br/>IAM reader/writer"]
            mod_sm["secret-manager/<br/>Secrets + versions,<br/>accessor bindings"]
            mod_log["logging/<br/>BigQuery dataset,<br/>log sink, exclusions"]
            mod_mon["monitoring/<br/>Dashboard, alerts,<br/>Pub/Sub, webhook"]
            mod_iam["iam/<br/>Service accounts,<br/>Workload Identity"]
        end
    end

    dev -- "terraform apply" --> main
    main --> mod_vpc
    main --> mod_gke
    main --> mod_ar
    main --> mod_sm
    main --> mod_log
    main --> mod_mon
    main --> mod_iam
    mod_gke -. "depends_on" .-> mod_vpc
    mod_iam -. "depends_on" .-> mod_gke
    mod_iam -. "depends_on" .-> mod_sm

    style main fill:#438DD5,color:#fff
    style mod_vpc fill:#85BBF0,color:#000
    style mod_gke fill:#85BBF0,color:#000
    style mod_ar fill:#85BBF0,color:#000
    style mod_sm fill:#85BBF0,color:#000
    style mod_log fill:#85BBF0,color:#000
    style mod_mon fill:#85BBF0,color:#000
    style mod_iam fill:#85BBF0,color:#000
```

## Level 4: Deployment Diagram

```mermaid
graph TB
    subgraph gcp ["Google Cloud Platform - us-central1"]
        subgraph gke ["GKE Cluster: srelab-gke<br/>Kubernetes 1.32, VPC-native"]
            subgraph system_pool ["System Node Pool<br/>2x n2-standard-2, 50GB pd-standard"]
                kube_system["kube-system<br/>CoreDNS, kube-proxy,<br/>Calico, GMP collector"]
            end

            subgraph user_pool ["User Node Pool<br/>3x n2-standard-2, 100GB pd-standard"]
                app_pods["Application Pods - cloudops ns<br/>store-front x2, store-admin x1<br/>order-service x2, product-service x2<br/>makeline-service x2, virtual-customer x1"]
                data_pods["Data Pods - cloudops ns<br/>mongodb x1 + PVC 8Gi<br/>rabbitmq x1"]
                obs_pods["Observability - cloudops ns<br/>grafana x1"]
            end
        end

        subgraph managed ["GCP Managed Services"]
            svc_mon["Cloud Monitoring<br/>2 alert policies, 1 dashboard"]
            svc_log["Cloud Logging<br/>Log sink to BigQuery<br/>90-day retention"]
            svc_ar["Artifact Registry<br/>srelab-docker repo"]
            svc_sm["Secret Manager<br/>2 secrets"]
            svc_ps["Pub/Sub<br/>srelab-metrics-alerts topic"]
        end
    end

    style kube_system fill:#438DD5,color:#fff
    style app_pods fill:#438DD5,color:#fff
    style data_pods fill:#438DD5,color:#fff
    style obs_pods fill:#438DD5,color:#fff
    style svc_mon fill:#85BBF0,color:#000
    style svc_log fill:#85BBF0,color:#000
    style svc_ar fill:#85BBF0,color:#000
    style svc_sm fill:#85BBF0,color:#000
    style svc_ps fill:#85BBF0,color:#000
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
