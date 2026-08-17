# Roast & Co.

## Overview

This **DevOps** project represents a containerized e-commerce-style coffee shop **Flask** app where users can browse products, add them to an order, change quantities, remove products, complete a simulated checkout, and submit ratings.

<img width="1260" height="1274" alt="image" src="https://github.com/user-attachments/assets/5d16ed44-57c8-47d0-affa-f71bfdaf401a" />

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
