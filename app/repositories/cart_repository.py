from database import get_db_connection


def add_cart_item(cart_id, product_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO cart_items (
                    cart_id,
                    product_id,
                    quantity
                )
                VALUES (%s, %s, 1)

                ON CONFLICT (cart_id, product_id)
                DO UPDATE
                SET quantity = cart_items.quantity + 1;
                """,
                (
                    cart_id,
                    product_id,
                ),
            )

def get_cart_items(cart_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    ci.product_id,
                    p.name,
                    p.category,
                    p.price,
                    p.image,
                    ci.quantity,
                    (p.price * ci.quantity) AS subtotal
                FROM cart_items ci
                JOIN products p
                    ON p.id = ci.product_id
                WHERE ci.cart_id = %s
                ORDER BY ci.id;
                """,
                (cart_id,),
            )

            rows = cursor.fetchall()

    return [
        {
            "product_id": row[0],
            "name": row[1],
            "category": row[2],
            "price": row[3],
            "image": row[4],
            "quantity": row[5],
            "subtotal": row[6],
        }
        for row in rows
    ]

def get_cart_total(cart_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    COALESCE(
                        SUM(p.price * ci.quantity),
                        0
                    )
                FROM cart_items ci
                JOIN products p
                    ON p.id = ci.product_id
                WHERE ci.cart_id = %s;
                """,
                (cart_id,),
            )

            row = cursor.fetchone()

    return row[0]

def get_cart_count(cart_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    COALESCE(
                        SUM(quantity),
                        0
                    )
                FROM cart_items
                WHERE cart_id = %s;
                """,
                (cart_id,),
            )

            row = cursor.fetchone()

    return row[0]

def increase_cart_item(cart_id, product_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE cart_items
                SET quantity = quantity + 1
                WHERE cart_id = %s
                  AND product_id = %s;
                """,
                (
                    cart_id,
                    product_id,
                ),
            )

def decrease_cart_item(cart_id, product_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE cart_items
                SET quantity = quantity - 1
                WHERE cart_id = %s
                  AND product_id = %s
                  AND quantity > 1;
                """,
                (
                    cart_id,
                    product_id,
                ),
            )

            if cursor.rowcount == 0:
                cursor.execute(
                    """
                    DELETE FROM cart_items
                    WHERE cart_id = %s
                      AND product_id = %s
                      AND quantity = 1;
                    """,
                    (
                        cart_id,
                        product_id,
                    ),
                )