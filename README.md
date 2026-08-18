# Roast & Co.

## Overview

This **DevOps** project represents a containerized e-commerce-style coffee shop **Flask** app where users can browse products, add them to an order, change quantities, remove products, complete a simulated checkout, and submit ratings.

Below you can familiarize yourself with the **main page**:

<img width="1251" height="1237" alt="image" src="https://github.com/user-attachments/assets/77501ed5-ae3f-460a-837a-2edff98a4f14" />


and the **cart page**, accordingly:

<img width="1081" height="613" alt="image" src="https://github.com/user-attachments/assets/6aa8b1b4-5d68-4f0b-8254-ba92302b20dd" />

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
