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