# Roast & Co.

## Overview

This **DevOps** project represents a containerized e-commerce-style coffee shop **Flask** app backed by **PostgreSQL**. Users can browse products, manage a persistent shopping cart, and save products to a wishlist.

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
│   └── init.sql
├── terraform/
│   ├── bakcend/
│   ├── bootstrap/
│   ├── environments/
│   └── modules/
│
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   └── hpa.yaml
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

## Current Runtime Architecture

```text
Browser
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
   │      │   ├── CSS
   │      │   ├── JavaScript
   │      │   └── Images
   │      │
   │      └── Repository Layer
   │          ├── Product Repository
   │          ├── Cart Repository
   │          └── Wishlist Repository
   │                 ↓
   │              psycopg
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

## Project status

Work in progress
