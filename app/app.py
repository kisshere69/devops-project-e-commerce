import os, psycopg

from flask import Flask, jsonify, render_template

app = Flask(__name__)

def get_db_connection():
    return psycopg.connect(DATABASE_URL)

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://coffee:coffee@localhost:5432/coffee_shop",
)

PRODUCTS = [
    {
        "id": 1,
        "name": "Cappuccino",
        "category": "Coffee",
        "price": 3.50,
        "description": "Espresso with steamed milk and a soft layer of foam.",
        "available": True,
        "image": "images/cappuccino.png",
    },
    {
        "id": 2,
        "name": "Flat White",
        "category": "Coffee",
        "price": 3.80,
        "description": "Double espresso with smooth steamed milk.",
        "available": True,
        "image": "images/flat white.png",
    },
    {
        "id": 3,
        "name": "Latte",
        "category": "Coffee",
        "price": 4.00,
        "description": "Espresso with plenty of creamy steamed milk.",
        "available": True,
        "image": "images/latte.png",
    },
    {
        "id": 4,
        "name": "Espresso",
        "category": "Coffee",
        "price": 2.40,
        "description": "A rich and concentrated shot of coffee.",
        "available": True,
        "image": "images/espresso.png",
    },
    {
        "id": 5,
        "name": "Butter Croissant",
        "category": "Pastry",
        "price": 2.90,
        "description": "Fresh flaky croissant baked with butter.",
        "available": True,
        "image": "images/golden croissant.png",
    },
    {
        "id": 6,
        "name": "Cinnamon Roll",
        "category": "Pastry",
        "price": 3.40,
        "description": "Soft cinnamon roll with a light glaze.",
        "available": True,
        "image": "images/glazed cinnamon.png",
    },
    {
        "id": 7,
        "name": "Cheesecake",
        "category": "Dessert",
        "price": 4.50,
        "description": "Creamy cheesecake with a biscuit base.",
        "available": True,
        "image": "images/creamy cheesecake.png",
    },
    {
        "id": 8,
        "name": "Chocolate Brownie",
        "category": "Dessert",
        "price": 3.60,
        "description": "Rich chocolate brownie with a soft center.",
        "available": False,
        "image": "images/unavailable brownie.png",
    },
]


@app.route("/")
def home():
    return render_template(
        "index.html",
        products=PRODUCTS,
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
    recommended_products = [
        product
        for product in PRODUCTS
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