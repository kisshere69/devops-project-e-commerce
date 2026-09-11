import os
from pathlib import Path

import psycopg


SECRET_FILE = Path("/mnt/secrets-store/DATABASE_URL")

if SECRET_FILE.exists():
    DATABASE_URL = SECRET_FILE.read_text(encoding="utf-8").strip()
else:
    DATABASE_URL = os.getenv(
        "DATABASE_URL",
        "postgresql://coffee:coffee@localhost:5432/coffee_shop",
    )


def get_db_connection():
    return psycopg.connect(DATABASE_URL)
