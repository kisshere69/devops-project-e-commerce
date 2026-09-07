import os
import subprocess
from pathlib import Path

import psycopg


def run_migrations() -> None:
    print("Running database migrations...")
    subprocess.run(
        ["python", "-m", "alembic", "upgrade", "head"],
        check=True,
    )


def run_seed() -> None:
    seed_file = Path("/app/database/seed/001_products.sql")

    print(f"Running database seed: {seed_file}")

    sql = seed_file.read_text(encoding="utf-8")

    database_url = os.environ["DATABASE_URL"].replace(
        "postgresql+psycopg://",
        "postgresql://",
    )

    with psycopg.connect(database_url) as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql)

    print("Database seed completed successfully.")


def main() -> None:
    run_migrations()
    run_seed()
    print("Database bootstrap completed successfully.")


if __name__ == "__main__":
    main()
