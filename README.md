# Roast & Co.

## Overview

This **DevOps** project represents a containerized e-commerce-style coffee shop **Flask** app backed by **PostgreSQL**. Users can browse products, manage a persistent shopping cart, and save products to a wishlist.

The app is designed to run locally with **Docker Compose** and is being progressively deployed to the **AWS Cloud**. The public app is available through the custom domain `www.roast-and-co.online`.

The project is designed as a **production-like** DevOps environment with **Docker**, **Kubernetes**, **AWS EKS**, **Terraform**, **CI/CD**, and **observability** introduced progressively.

---
## Main page:

<img width="1092" height="1216" alt="image" src="https://github.com/user-attachments/assets/2f44a7fb-942a-4fc4-a272-0113cca1242e" />

---

## Cart page:

<img width="1092" height="823" alt="image" src="https://github.com/user-attachments/assets/997fcf9a-c23a-4e92-8162-af557d7846f0" />

---

## Wishlist page:

<img width="1079" height="630" alt="image" src="https://github.com/user-attachments/assets/5a1a4a01-7480-4796-a75f-517b2a60bb26" />

---

## Project Architecture (Work in progress)
```text
devops-project-e-commerce/
├── app/
│   ├── app.py
│   ├── database.py
│   ├── logging_config.py
│   ├── requirements.txt
│   │
│   ├── repositories/
│   │   ├── __init__.py
│   │   ├── product_repository.py
│   │   ├── cart_repository.py
│   │   └── wishlist_repository.py
│   │
│   ├── templates/
│   │   ├── base.html
│   │   ├── index.html
│   │   ├── cart.html
│   │   └── wishlist.html
│   │
│   └── static/
│       ├── css/
│       │   └── style.css
│       ├── images/
│       └── js/
│           └── navigation.js
│
├── database/
│   ├── migrations/                             # schema
│   ├── versions/                               # source of truth
│   │   └── 644cbbd0a5e2_initial_schema.py
│   │
│   ├── seed/                                   # initial data
│   │   └──001_products.sql
│   │
│   ├── bootstrap/                              # db bootstrap
│   │   ├── Dockerfile                          # db migration image
│   │   └── bootstrap.py
│   │
│   └── init.sql                                # db data for local testing
│
├── terraform/
│   ├── bakcend/                                # tfstate backend
│   ├── bootstrap/                              # AWS bootstrap
│   ├── environments/
│   │   └── dev/
│   │
│   └── modules/
│       ├── vpc/
│       ├── ecr/
│       ├── eks/
│       ├── rds/
│       ├── acm-certificate/
│       └── alb-controller/
│
├── k8s/
│   ├── namespace.yaml
│   ├── service-account.yaml
│   ├── db-migration-serviceaccount.yaml
│   ├── db-secret-provider.yaml
│   ├── db-migration-job.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
│
├── load-testing/
│   └── k6/
│       └── smoke.js
│
├── observability/
│   ├── prometheus/
│   │   └── prometheus.yml
│   │
│   └── grafana/
│       ├── dashboards/
│       │   └── requests-dashboard.json
│       │
│       └── provisioning/
│           ├── dashboards/
│           │   └── dashboard.yml
│           │
│           └── datasources/
│               └── datasource.yml
│
├── .github/
│   └── workflows/
│       ├── ci-cd.yaml
│       └── db-migration.yaml
│
├── Dockerfile
├── docker-compose.yaml
├── .dockerignore
├── .gitignore
└── README.md
```

## Endpoints

- `/` - storefront
- `/health` - application health check
- `/health/db` - database health check
- `/cart` - shopping cart health check
- `/wishlist` - wishlist health check
- `/cart/add/<product_id>` - add product to cart
- `/cart/increase/<id>` - increase product quantity
- `/cart/decrease/<id>` - decrease product quantity
- `/cart/remove/<id>` - remove product from cart
- `/cart/clear` - clear shopping cart
- `/wishlist/add/<product_id>` - add product to wishlist
- `/wishlist/remove/<product_id>` - remove product from wishlist
- `/metrics` - Prometheus scraping

## Current Local Runtime Architecture

```text
www.roast-and-co.online
          ↓
       Cloudflare
          ↓
   Cloudflare Tunnel
          ↓
    Docker Compose
          │
          ├── Application Container
          │      ↓
          │   Gunicorn
          │      ↓
          │    Flask
          │      │
          │      ├── Jinja Templates
          │      ├── Static Assets
          │      │      ├── CSS
          │      │      ├── JavaScript
          │      │      └── Images
          │      │
          │      ├── Structured Logging
          │      │      ├── JSON Logs
          │      │      ├── Request IDs
          │      │      └── Request Duration
          │      │
          │      ├── Prometheus Metrics
          │      │      └── /metrics
          │      │
          │      └── Repository Layer
          │             ├── Product Repository
          │             ├── Cart Repository
          │             └── Wishlist Repository
          │                    ↓
          │                 psycopg
          │                    ↓
          │
          └── PostgreSQL Container
                 ↓
            Persistent Volume
                 ↓
             PostgreSQL
                 ├── products
                 ├── cart_items
                 └── wishlist_items
```

## AWS Runtime Architecture

```text
Internet
   │
   ▼
Cloudflare
   │
   ├── roast-and-co.online ──► Amazon ALB
   │                              │
   │                              ▼
   │                           AWS EKS
   │                              │
   │                    ┌─────────┴─────────┐
   │                    │                   │
   │                 Flask Pod           Flask Pod
   │                    │                   │
   │                    └─────────┬─────────┘
   │                              │
   │                     PostgreSQL connection
   │                              │
   │                              ▼
   │                       Amazon RDS PostgreSQL
   │
   └── www.roast-and-co.online ──► Cloudflare Tunnel
```

## Proof of Concept

The PoC demonstrates that the project can provision AWS infrastructure, deploy the application to EKS, connect the application to Amazon RDS PostgreSQL, expose the application through an AWS ALB, and subsequently destroy the environment using Terraform.

### Terraform Infrastructure

The EKS environment was successfully created with:
```bash
EKS Cluster:        roast-co-dev
AWS Region:         eu-central-1
Kubernetes Version: 1.36
Worker Node Group:  general
Desired Nodes:      2
Minimum Nodes:      1
Maximum Nodes:      3
Instance Type:      t3.small
```

Terraform successfully produced a clean deployment plan:

`Plan: 59 to add, 0 to change, 0 to destroy.`

The infrastructure included:
```text
VPC
├── Public Subnets
├── Private Subnets
├── Internet Gateway
├── NAT Gateway
└── Route Tables

EKS
├── Control Plane
├── Managed Node Group
└── Kubernetes system components

ECR
RDS PostgreSQL
AWS Secrets Manager
IAM
ACM
AWS Load Balancer Controller
```

### EKS Cluster Validation

The EKS cluster successfully reached the ACTIVE state:
```bash
$ aws eks describe-cluster \
    --name roast-co-dev \
    --region eu-central-1

Status:  ACTIVE
Version: 1.36
```

Kubernetes access was then verified:
```bash
$ kubectl get nodes

NAME                                           STATUS   ROLES    AGE   VERSION
ip-10-0-11-22.eu-central-1.compute.internal    Ready    <none>   18m   v1.36.3-eks-cb19647
ip-10-0-12-221.eu-central-1.compute.internal   Ready    <none>   18m   v1.36.3-eks-cb19647
```
Both worker nodes reached the `Ready` state.

The nodes were distributed across the configured private subnets/Availability Zones.

### Kubernetes System Components

The EKS system workloads were successfully validated:
```bash
$ kubectl get pods -A

NAMESPACE     NAME                             READY   STATUS    RESTARTS
kube-system   aws-node-hgq7m                   2/2     Running   0
kube-system   aws-node-ldm7q                   2/2     Running   0
kube-system   coredns-c4b9957df-p885w          1/1     Running   0
kube-system   coredns-c4b9957df-vqp7c          1/1     Running   0
kube-system   eks-pod-identity-agent-dkhrt     1/1     Running   0
kube-system   eks-pod-identity-agent-nt9rp     1/1     Running   0
kube-system   kube-proxy-fq2ff                 1/1     Running   0
kube-system   kube-proxy-jqks9                 1/1     Running   0
kube-system   secrets-store-csi-driver-qx628   3/3     Running   0
kube-system   secrets-store-csi-driver-rq99v   3/3     Running   0
```

This validated the operation of:

- Amazon VPC CNI
- CoreDNS
- kube-proxy
- EKS Pod Identity Agent
- Secrets Store CSI Driver


### EKS Pod Identity

AWS Pod Identity associations were verified:
```bash
$ aws eks list-pod-identity-associations \
    --region eu-central-1 \
    --cluster-name roast-co-dev

namespace       serviceAccount
dev             db-migration
kube-system     alb-controller
kube-system     aws-node
```

Different Kubernetes workloads therefore used dedicated IAM roles.

The application workload also used its own Kubernetes ServiceAccount - `roast-co-app` to provide the application with access to the required AWS resources.

```bash
$ kubectl get serviceaccount roast-co-app -n dev 
NAME              AGE
roast-co-app      6s
```

### AWS Secrets Manager and CSI

The RDS credentials were stored in AWS Secrets Manager:

```bash
Name:
roast-co-dev-rds-credentials

Status:
AWSCURRENT
```
The credentials were delivered to Kubernetes using:

```text
AWS Secrets Manager
        │
        ▼
EKS Pod Identity
        │
        ▼
Secrets Store CSI Driver
        │
        ▼
Mounted secret file
        │
        ▼
Application / Migration Job
```

Therefore, database connection was not hard-coded into the Kubernetes Deployment.

The Secrets Store CSI Driver was successfully running inside the EKS cluster.

### Database Migration

The PostgreSQL database schema was managed using Alembic.

The Kubernetes migration Job successfully executed:

```bash
$ kubectl get jobs -n dev

NAME            COMPLETIONS   DURATION   AGE
db-migration    1/1           6s         50m
```

The seed script was made idempotent so that the database bootstrap process could safely be retried:

```sql
ON CONFLICT (id) DO UPDATE

SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    price = EXCLUDED.price,
    description = EXCLUDED.description,
    available = EXCLUDED.available,
    image = EXCLUDED.image;
```

### Application Deployment

The Flask application was deployed to EKS with 2 replicas:

```bash
$ kubectl get deploy -n dev

NAME        READY    UP-TO-DATE   AVAILABLE   AGE
roast-co    2/2      2            2           25m

$ kubectl get pods -n dev

NAME                         READY    STATUS      RESTARTS   AGE
db-migration-mkpkt           0/1      Completed      0       54m
roast-co-644976cbf7-6jznb    1/1      Running        0       25m
roast-co-644976cbf7-d4ml9    1/1      Running        0       25m
```

### External Access

The Flask application was exposed externally through a Kubernetes Ingress managed by the AWS ALB.

The Ingress was configured with:

- **Ingress class:** `alb`
- **Host:** `roast-and-co.online`
- **Load balancer:** AWS Application Load Balancer
- **Listener:** HTTP/HTTPS
- **Target type:** IP
- **TLS:** AWS ACM certificate

The Kubernetes Ingress was successfully created and associated with the application domain:

```bash
$ kubectl get ingress -n dev

NAME                    CLASS   HOSTS                 ADDRESS   PORTS
roast-co-dev-ingress    alb     roast-and-co.online   ...       80
```

## Project status

Work in progress
