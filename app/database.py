import os, psycopg

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://coffee:coffee@localhost:5432/coffee_shop",
)

def get_db_connection():
    return psycopg.connect(DATABASE_URL)