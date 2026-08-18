import os, uuid

from flask import (
    Flask,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from database import get_db_connection
from repositories.product_repository import get_product, get_products
from repositories.cart_repository import (
    add_cart_item,
    get_cart_count,
    get_cart_items,
    get_cart_total,
)

app = Flask(__name__)

app.config["SECRET_KEY"] = os.getenv(
    "SECRET_KEY",
    "dev-secret-key"
)

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
    cart_id = session.get("cart_id")

    if cart_id is None:
        cart_items = []
        cart_total = 0
    else:
        cart_items = get_cart_items(cart_id)
        cart_total = get_cart_total(cart_id)

    products = get_products()

    recommended_products = [
        product
        for product in products
        if product["available"]
    ][:3]

    return render_template(
        "cart.html",
        cart_items=cart_items,
        cart_total=cart_total,
        recommended_products=recommended_products,
    )


def get_cart_id():
    if "cart_id" not in session:
        session["cart_id"] = str(uuid.uuid4())

    return session["cart_id"]

@app.route(
    "/cart/add/<int:product_id>",
    methods=["POST"],
)

def add_to_cart(product_id):
    product = get_product(product_id)

    if product is None:
        return "Product not found", 404

    if not product["available"]:
        return "Product is unavailable", 400

    cart_id = get_cart_id()

    add_cart_item(
        cart_id,
        product_id,
    )

    flash(
        f"{product['name']} was added to your cart.",
        "cart",
    )

    return redirect(
        request.referrer or url_for("home")
    )


@app.context_processor
def inject_cart_count():
    cart_id = session.get("cart_id")

    if cart_id is None:
        return {
            "cart_count": 0,
        }

    return {
        "cart_count": get_cart_count(cart_id),
    }

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