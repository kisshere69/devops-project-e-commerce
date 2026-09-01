import os, uuid, logging, time

from flask import (
    Flask,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    session,
    url_for,
    g,
    request
)
from database import get_db_connection
from repositories.product_repository import get_product, get_products
from repositories.cart_repository import (
    add_cart_item,
    get_cart_count,
    get_cart_items,
    get_cart_total,
    clear_cart,
    increase_cart_item,
    decrease_cart_item,
    remove_cart_item,
)
from repositories.wishlist_repository import (
    add_wishlist_item,
    get_wishlist_items,
    get_wishlist_count,
    remove_wishlist_item,
)

from logging_config import configure_logging

configure_logging()

logger = logging.getLogger(__name__)
logger.info("Application started")

app = Flask(__name__)

app.config["SECRET_KEY"] = os.getenv(
    "SECRET_KEY",
    "dev-secret-key"
)

@app.before_request
def start_request_timer():
    g.request_start_time = time.perf_counter()

@app.after_request
def log_request(response):
    duration_ms = round(
        (time.perf_counter() - g.request_start_time) * 1000,
        2,
    )

    logger.info(
        "Request completed",
        extra={
            "method": request.method,
            "path": request.path,
            "status_code": response.status_code,
            "duration_ms": duration_ms,
        },
    )

    return response

@app.route("/")
def home():
    products = get_products()

    return render_template(
        "index.html",
        products=products,
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

# Cart

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
def inject_header_counts():
    cart_id = session.get("cart_id")
    wishlist_id = session.get("wishlist_id")

    cart_count = (
        get_cart_count(cart_id)
        if cart_id
        else 0
    )

    wishlist_count = (
        get_wishlist_count(wishlist_id)
        if wishlist_id
        else 0
    )

    return {
        "cart_count": cart_count,
        "wishlist_count": wishlist_count,
    }

@app.route(
    "/cart/clear",
    methods=["POST"],
)
def clear_cart_route():
    cart_id = session.get("cart_id")

    if cart_id is not None:
        clear_cart(cart_id)

    return redirect(url_for("cart"))

@app.route(
    "/cart/increase/<int:product_id>",
    methods=["POST"],
)
def increase_cart_product(product_id):
    cart_id = session.get("cart_id")

    if cart_id is not None:
        increase_cart_item(
            cart_id,
            product_id,
        )

    return redirect(url_for("cart"))


@app.route(
    "/cart/decrease/<int:product_id>",
    methods=["POST"],
)
def decrease_cart_product(product_id):
    cart_id = session.get("cart_id")

    if cart_id is not None:
        decrease_cart_item(
            cart_id,
            product_id,
        )

    return redirect(url_for("cart"))

@app.route(
    "/cart/remove/<int:product_id>",
    methods=["POST"],
)
def remove_cart_product(product_id):
    cart_id = session.get("cart_id")

    if cart_id is not None:
        remove_cart_item(
            cart_id,
            product_id,
        )

    return redirect(url_for("cart"))

# Wishlist

@app.route("/wishlist")
def wishlist():
    wishlist_id = session.get("wishlist_id")

    if wishlist_id is None:
        wishlist_items = []
    else:
        wishlist_items = get_wishlist_items(wishlist_id)

    return render_template(
        "wishlist.html",
        wishlist_items=wishlist_items,
    )

def get_wishlist_id():
    if "wishlist_id" not in session:
        session["wishlist_id"] = str(uuid.uuid4())

    return session["wishlist_id"]

@app.route("/wishlist/add/<int:product_id>", methods=["POST"])
def add_to_wishlist(product_id):
    product = get_product(product_id)

    if product is None:
        return "Product not found", 404

    wishlist_id = get_wishlist_id()

    add_wishlist_item(
        wishlist_id,
        product_id,
    )

    flash(
        f"{product['name']} was added to your wishlist.",
        "wishlist",
    )

    return redirect(
        request.referrer or url_for("home")
    )

@app.route("/wishlist/remove/<int:product_id>", methods=["POST"])
def remove_from_wishlist(product_id):
    wishlist_id = session.get("wishlist_id")

    if wishlist_id is not None:
        remove_wishlist_item(
            wishlist_id,
            product_id,
        )

    return redirect(url_for("wishlist"))

# App health checks

@app.route("/health")
def health():
    return jsonify(
        {
            "status": "healthy",
        }
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