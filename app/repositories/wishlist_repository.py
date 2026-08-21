from database import get_db_connection

def add_wishlist_item(wishlist_id, product_id):
    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO wishlist_items (wishlist_id, product_id)
                VALUES (%s, %s)
                ON CONFLICT (wishlist_id, product_id)
                DO NOTHING;
                """,
                (wishlist_id, product_id),
            )

        connection.commit()

    finally:
        connection.close()


def get_wishlist_items(wishlist_id):
    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    wi.product_id,
                    p.name,
                    p.category,
                    p.price,
                    p.image
                FROM wishlist_items wi
                JOIN products p
                    ON wi.product_id = p.id
                WHERE wi.wishlist_id = %s
                ORDER BY wi.id DESC;
                """,
                (wishlist_id,),
            )

            rows = cursor.fetchall()

            return [
                {
                    "product_id": row[0],
                    "name": row[1],
                    "category": row[2],
                    "price": row[3],
                    "image": row[4],
                }
                for row in rows
            ]

    finally:
        connection.close()

def get_wishlist_count(wishlist_id):
    connection = get_db_connection()

    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*)
                FROM wishlist_items
                WHERE wishlist_id = %s;
                """,
                (wishlist_id,),
            )

            row = cursor.fetchone()
            return row[0]

    finally:
        connection.close()