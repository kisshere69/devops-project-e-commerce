from database import get_db_connection

def get_products():
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    id,
                    name,
                    category,
                    price,
                    description,
                    available,
                    image
                FROM products
                ORDER BY id;
                """
            )

            rows = cursor.fetchall()

    return [
        {
            "id": row[0],
            "name": row[1],
            "category": row[2],
            "price": row[3],
            "description": row[4],
            "available": row[5],
            "image": row[6],
        }
        for row in rows
    ]


def get_product(product_id):
    with get_db_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    id,
                    name,
                    category,
                    price,
                    description,
                    available,
                    image
                FROM products
                WHERE id = %s;
                """,
                (product_id,),
            )

            row = cursor.fetchone()

    if row is None:
        return None

    return {
        "id": row[0],
        "name": row[1],
        "category": row[2],
        "price": row[3],
        "description": row[4],
        "available": row[5],
        "image": row[6],
    }
