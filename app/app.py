from flask import Flask, jsonify, render_template
from database import get_db_connection
from repositories.product_repository import (
    get_product,
    get_products,
)

app = Flask(__name__)

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

@app.route("/api/products/<int:product_id>")
def product_api(product_id):
    product = get_product(product_id)

    if product is None:
        return jsonify(
            {
                "error": "Product not found",
            }
        ), 404

    return jsonify(product)

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