import os
from pathlib import Path

import psycopg


SECRET_FILE = Path("/mnt/secrets-store/DATABASE_URL")

if SECRET_FILE.exists():
    DATABASE_URL = SECRET_FILE.read_text(encoding="utf-8").strip()
else:
    DATABASE_URL = os.getenv("DATABASE_URL")
    
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

def get_db_connection():
    database_url = DATABASE_URL.replace(
        "postgresql+psycopg://",
        "postgresql://",
    )
    return psycopg.connect(database_url)
