# GCP SRE Agent Sandbox - C4 Architecture Diagrams

## Level 1: System Context Diagram

```mermaid
flowchart TB
    sre["SRE Engineer\n\nDiagnoses and remediates\napplication issues"]
    dev["Developer\n\nDeploys infrastructure\nand applications"]

    srelab(["GCP SRE Agent Sandbox\n\nGKE-based e-commerce demo\nwith breakable scenarios\nfor SRE training"])

    gemini[/"Gemini in Cloud Logging\n\nAI-powered log analysis\nand diagnosis"/]
    ghcr[/"GitHub Container Registry\n\nghcr.io/gcp-sre-agent/\nstore-demo images"/]
    gcp_iam[/"Google Cloud IAM\n\nIdentity and access\nmanagement"/]

    sre -- "Diagnoses failures,\napplies scenarios\n(kubectl, gcloud)" --> srelab
    dev -- "Deploys & manages\ninfrastructure\n(Terraform, bash scripts)" --> srelab
    sre -- "Queries logs with\nnatural language" --> gemini
    srelab -- "Pulls container images" --> ghcr
    srelab -- "Authenticates via\nWorkload Identity" --> gcp_iam
```

## Level 2: Container Diagram

```mermaid
flowchart TB
    sre["SRE Engineer"]
    dev["Developer"]

    subgraph gcp ["Google Cloud Platform"]

        subgraph gke ["GKE Cluster (srelab-gke)"]

            subgraph cloudops_ns ["Namespace: cloudops"]
                storefront["store-front\nVue.js\n:8080"]
                storeadmin["store-admin\nVue.js\n:8081"]
                orderservice["order-service\nNode.js\n:3000"]
                productservice["product-service\nRust\n:3002"]
                makelineservice["makeline-service\nGo\n:3001"]
                virtualcustomer["virtual-customer\nLoad Gen"]
                mongodb[("MongoDB 4.4\nOrder database\nPD: standard-rwo")]
                rabbitmq["RabbitMQ 3.11\nMessage queue\nAMQP :5672"]
                grafana["Grafana 10.0\nDashboards :3000\nLB :80"]
            end

            gmp["GMP PodMonitoring\nCRDs\nMetrics scraping 30s"]
        end

        subgraph infra ["GCP Managed Services"]
            secretmgr[("Secret Manager\nmongodb-password\nrabbitmq-password")]
            cloudlogging["Cloud Logging\nk8s_container &\nk8s_pod logs"]
            bigquery[("BigQuery\nLog sink dataset\n90-day retention")]
            cloudmon["Cloud Monitoring\nAlert policies\n& dashboards"]
            artifactreg["Artifact Registry\nDocker repo:\nsrelab-docker"]
            pubsub["Pub/Sub\nAlert notifications"]
        end

        subgraph network ["VPC: srelab-network"]
            subnet_pods["Subnet: pods\n10.0.0.0/22"]
            subnet_svc["Subnet: services\n10.0.4.0/24"]
            nat["Cloud NAT\nOutbound internet"]
        end
    end

    sre -- "Browses store\nHTTP :80 LB" --> storefront
    sre -- "Views dashboards\nHTTP :80 LB" --> grafana
    dev -- "Manages cluster\nkubectl, terraform" --> gke
    storefront -- "Places orders\nHTTP" --> orderservice
    storefront -- "Lists products\nHTTP" --> productservice
    storeadmin -- "Manages products\nHTTP" --> productservice
    storeadmin -- "Views orders\nHTTP" --> makelineservice
    orderservice -- "Publishes orders\nAMQP :5672" --> rabbitmq
    makelineservice -- "Consumes orders\nAMQP :5672" --> rabbitmq
    makelineservice -- "Stores orders\nTCP :27017" --> mongodb
    virtualcustomer -- "Generates load\nHTTP" --> orderservice
    cloudlogging -- "Sinks logs\nLog Router" --> bigquery
    cloudmon -- "Fires alerts\nNotification Channel" --> pubsub
    grafana -- "Queries metrics\nStackdriver API" --> cloudmon
    gmp -- "Exports metrics\nGMP pipeline" --> cloudmon
```

## Level 3: Component Diagram (Infrastructure as Code)

```mermaid
flowchart TB
    dev["Developer"]

    subgraph terraform ["infra/terraform/"]

        main["main.tf\nRoot Module\nOrchestrates all modules,\nconfigures providers"]
        variables["variables.tf\nVariables\ngcp_project_id, gcp_region,\nworkload_name, passwords"]
        outputs["outputs.tf\nOutputs\ncluster_endpoint, registry_url,\ndashboard_ids"]

        subgraph modules ["modules/"]
            mod_vpc["vpc/\nNetwork Module\nVPC, subnets, firewall,\nCloud NAT, router"]
            mod_gke["gke/\nGKE Module\nCluster, node pools,\nStorageClasses (CSI)"]
            mod_ar["artifact-registry/\nRegistry Module\nDocker repo,\nIAM reader/writer"]
            mod_sm["secret-manager/\nSecrets Module\nSecrets + versions,\naccessor bindings"]
            mod_log["logging/\nLogging Module\nBigQuery dataset,\nlog sink, exclusions"]
            mod_mon["monitoring/\nMonitoring Module\nDashboard, alerts,\nPub/Sub, webhook"]
            mod_iam["iam/\nIAM Module\nService accounts,\nWorkload Identity bindings"]
        end
    end

    dev -- "terraform apply\nCLI" --> main
    main -- "network_name, CIDRs, region" --> mod_vpc
    main -- "project_id, cluster_name,\nvpc outputs, k8s version" --> mod_gke
    main -- "project_id, region,\ngke SA email" --> mod_ar
    main -- "project_id, secrets map,\ngke SA email" --> mod_sm
    main -- "project_id, region,\nsink_name, dataset" --> mod_log
    main -- "project_id, region,\ncluster_name, webhook_url" --> mod_mon
    main -- "project_id, cluster_name,\nWI pool, SA configs" --> mod_iam
    mod_gke -. "depends_on\nnetwork_name, subnet_name" .-> mod_vpc
    mod_iam -. "depends_on\ncluster outputs" .-> mod_gke
    mod_iam -. "depends_on\nsecret access" .-> mod_sm
```

## Level 4: Deployment Diagram

```mermaid
flowchart TB
    subgraph gcp ["Google Cloud Platform (us-central1)"]

        subgraph gke ["GKE Cluster: srelab-gke\nKubernetes 1.32, VPC-native"]

            subgraph system_pool ["System Node Pool\n2x n2-standard-2, 50GB pd-standard"]
                kube_system["kube-system\nCoreDNS, kube-proxy,\nCalico, GMP collector"]
            end

            subgraph user_pool ["User Node Pool\n3x n2-standard-2, 100GB pd-standard"]
                app_pods["Application Pods (cloudops ns)\nstore-front (2), store-admin (1)\norder-service (2), product-service (2)\nmakeline-service (2), virtual-customer (1)"]
                data_pods["Data Pods (cloudops ns)\nmongodb (1) + PVC 8Gi\nrabbitmq (1)"]
                obs_pods["Observability Pods (cloudops ns)\ngrafana (1)"]
            end
        end

        subgraph managed ["GCP Managed Services"]
            svc_mon["Cloud Monitoring\n2 alert policies, 1 dashboard"]
            svc_log["Cloud Logging\nLog sink to BigQuery\n90-day retention"]
            svc_ar["Artifact Registry\nsrelab-docker repo"]
            svc_sm["Secret Manager\n2 secrets (auto-replicated)"]
            svc_ps["Pub/Sub\nsrelab-metrics-alerts topic"]
        end
    end
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
