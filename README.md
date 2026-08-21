# Roast & Co.

## Overview

This **DevOps** project represents a containerized e-commerce-style coffee shop **Flask** app where users can browse products, add them to an order, change quantities, remove products, complete a simulated checkout, and submit ratings.

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
```
devops-project-e-commerce/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   │
│   ├── repositories/
│   │   └── product_repository.py
│   │
│   ├── templates/
│   │   ├── base.html
│   │   ├── index.html
│   │   ├── wishlist.html           # planned
│   │   └── cart.html
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
│
├── Dockerfile                     # planned
├── docker-compose.yaml
├── .gitignore
└── README.md
```

## Endpoints

- `/` - storefront
- `/health` - application health check
- `/health/db` - database health check

## Near-term Architecture

```text
Browser
   ↓
Flask
   ├── Jinja Templates
   ├── Static Assets
   │   ├── CSS
   │   ├── JavaScript
   │   └── Images
   │
   └── Product Repository
          ↓
       psycopg
          ↓
      PostgreSQL
          ↓
       products
```

## Project status

Work in progress
