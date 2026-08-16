import os, psycopg

from flask import Flask, jsonify, render_template

app = Flask(__name__)

def get_db_connection():
    return psycopg.connect(DATABASE_URL)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://coffee:coffee@localhost:5432/coffee_shop",
)

def get_products():
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT *
                FROM products
                ORDER BY id;
                """
            )

            rows = cursor.fetchall()

    products = []

    for row in rows:
        products.append(
            {
                "id": row[0],
                "name": row[1],
                "category": row[2],
                "price": row[3],
                "description": row[4],
                "available": row[5],
                "image": row[6],
            }
        )

    return products


@app.route("/")
def home():
    products = get_products()

    return render_template(
        "index.html",
        products=products,
    )


@app.route("/health")
def health():
    return jsonify(
        {
            "status": "healthy",
        }
    )

@app.route("/cart")
def cart():
    products = get_products()
    
    recommended_products = [
        product
        for product in products
        if product["available"]
    ][:3]

    return render_template(
        "cart.html",
        recommended_products=recommended_products,
    )

@app.route("/health/db")
def database_health():
    try:
        with get_db_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1;")
                result = cursor.fetchone()

        return jsonify(
            {
                "status": "healthy",
                "database": "reachable",
                "result": result[0],
            }
        )

    except Exception as error:
        return jsonify(
            {
                "status": "unhealthy",
                "database": "unreachable",
                "error": str(error),
            }
        ), 500

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
    )