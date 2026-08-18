CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    description TEXT NOT NULL,
    available BOOLEAN NOT NULL DEFAULT TRUE,
    image VARCHAR(255) NOT NULL
);


INSERT INTO products (
    id,
    name,
    category,
    price,
    description,
    available,
    image
)
VALUES
    (
        1,
        'Cappuccino',
        'Coffee',
        3.50,
        'Espresso with steamed milk and a soft layer of foam.',
        TRUE,
        'images/cappuccino.png'
    ),
    (
        2,
        'Flat White',
        'Coffee',
        3.80,
        'Double espresso with smooth steamed milk.',
        TRUE,
        'images/flat white.png'
    ),
    (
        3,
        'Latte',
        'Coffee',
        4.00,
        'Espresso with plenty of creamy steamed milk.',
        TRUE,
        'images/latte.png'
    ),
    (
        4,
        'Espresso',
        'Coffee',
        2.40,
        'A rich and concentrated shot of coffee.',
        TRUE,
        'images/espresso.png'
    ),
    (
        5,
        'Butter Croissant',
        'Pastry',
        2.90,
        'Fresh flaky croissant baked with butter.',
        TRUE,
        'images/golden croissant.png'
    ),
    (
        6,
        'Cinnamon Roll',
        'Pastry',
        3.40,
        'Soft cinnamon roll with a light glaze.',
        TRUE,
        'images/glazed cinnamon.png'
    ),
    (
        7,
        'Cheesecake',
        'Dessert',
        4.50,
        'Creamy cheesecake with a biscuit base.',
        TRUE,
        'images/creamy cheesecake.png'
    ),
    (
        8,
        'Chocolate Brownie',
        'Dessert',
        3.60,
        'Rich chocolate brownie with a soft center.',
        FALSE,
        'images/unavailable brownie.png'
    )
ON CONFLICT (id) DO NOTHING;


CREATE TABLE IF NOT EXISTS cart_items (
    id SERIAL PRIMARY KEY,
    cart_id VARCHAR(50) NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT fk_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE,

    CONSTRAINT unique_cart_product
        UNIQUE (cart_id, product_id),

    CONSTRAINT positive_quantity
        CHECK (quantity > 0)
);
