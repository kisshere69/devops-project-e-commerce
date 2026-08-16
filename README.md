# Roast & Co.

## Overview

This **DevOps** project represents a lightweight e-commerce-style coffee shop app where users can browse coffee, pastries, and desserts, add items to an order, change quantities, remove products, complete a simulated checkout, and submit ratings.

## Project Architecture (initial)

```
app/
├── app.py
├── requirements.txt
│
├── templates/
│   ├── base.html
│   └── index.html
│
├── static/
│   ├── css/
│   │   └── style.css
│   │   └── images/
│   │
│   └── js/
│       └──navigation.js
│
├── .gitignore
└── README.md
```

## Endpoints

- `/` — storefront
- `/health` — application health check

## Current architecture

```
Browser
↓
Flask
↓
Jinja Templates
↓
Static Assets
```

Product data is currently stored in memory inside the Flask application.

## Project status

Work in progress