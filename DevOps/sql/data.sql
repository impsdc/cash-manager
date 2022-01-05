DROP TABLE IF EXISTS cart_products;
DROP TABLE IF EXISTS transaction_products;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users
(
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    enabled BOOLEAN DEFAULT FALSE,
    role VARCHAR(32) NOT NULL CONSTRAINT check_roles
    CHECK (role IN ('ROLE_USER', 'ROLE_ADMIN') )
);

CREATE TABLE IF NOT EXISTS carts
(
    user_id INT PRIMARY KEY,
    start_date DATE DEFAULT NULL,
    CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS transactions
(
    id SERIAL PRIMARY KEY,
    total_bill FLOAT NOT NULL,
    transaction_date TIMESTAMP DEFAULT NULL,
    payment_mode VARCHAR(128) DEFAULT NULL,
    user_id INT NOT NULL,
    UNIQUE (user_id, id),
    CONSTRAINT fk_transactions_user FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE IF NOT EXISTS products
(
    id SERIAL PRIMARY KEY,
    code VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    img_url VARCHAR(128) DEFAULT NULL,
    description VARCHAR(256) NOT NULL,
    price FLOAT NOT NULL,
    quantity INT NOT NULL
);

CREATE TABLE IF NOT EXISTS cart_products
(
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (cart_id, product_id),
    CONSTRAINT fk_cartproducts_cart FOREIGN KEY (cart_id) REFERENCES carts (user_id),
    CONSTRAINT fk_cartproducts_product FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TABLE IF NOT EXISTS transaction_products
(
    transaction_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (transaction_id, product_id),
    CONSTRAINT fk_transactionproducts_transaction FOREIGN KEY (transaction_id) REFERENCES transactions (id),
    CONSTRAINT fk_transactionproducts_product FOREIGN KEY (product_id) REFERENCES products (id)
);

TRUNCATE transaction_products, cart_products, transactions, carts, products, users;

INSERT INTO users (username, password, role, enabled) VALUES
    ('admin', '$2a$10$Lifw3tSs5.DXsqlk5QU4UOwETeB3IXV97RsPPbFOOOnvKAveHXhiO', 'ROLE_ADMIN', true),
    ('remi', '$2a$10$moyqbPrLyayLRyf2TCDVgOkYG5Xj5olt9gIeweIrbfQGAgk8FQ.tC', 'ROLE_USER', true),
    ('user', '$2a$10$to4KDJvQOBJHW25SbcfpNu4e4BwbMPbelycEmbUhvt36SL8GVBf9e', 'ROLE_USER', true);

INSERT INTO carts (user_id) VALUES
    (1),
    (2),
    (3);

INSERT INTO products (code, name, img_url, description, price, quantity) VALUES
    (6436765, 'Tomate', 'https://fr.openfoodfacts.org/images/products/350/418/292/0011/front_fr.99.400.jpg', 'Pellentesque ullamcorper metus id tellus dignissim ultricies. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.', 1.99, 72),
    (6436763, 'Tzatziki', 'https://fr.openfoodfacts.org/images/products/325/622/026/9742/front_fr.43.400.jpg', 'Vivamus ultrices, erat ac dictum commodo, metus tellus ornare mi, vitae elementum quam massa nec risus. Vestibulum porta nibh quis erat porta', 1.32, 18),
    (6436761, 'Avocat', 'https://fr.openfoodfacts.org/images/products/20562328/front_fr.3.400.jpg', 'Nulla ipsum ante, pulvinar feugiat tempor sit amet, feugiat non nibh. Morbi dictum, augue ac efficitur commodo, urna lorem tempus nisi', 2.99, 27),
    (6436769, 'Salade', 'https://fr.openfoodfacts.org/images/products/308/368/108/1534/front_fr.169.400.jpg', 'sit amet elementum ligula rhoncus in. Nulla tincidunt nibh sit amet justo tincidunt pulvinar. Donec quis ullamcorper magna. ', 1.99, 14),
    (6436770, 'Saumon', 'https://fr.openfoodfacts.org/images/products/17601223/front_fr.16.400.jpg', 'Etiam id sapien id neque malesuada venenatis et ac velit. Fusce sed metus ac felis interdum fermentum. Proin eu ligula faucibus, posuere risus id, suscipit nisi. Proin lobortis venenatis enim', 5.99, 9),
    (3068320120256, 'Evian 1.5L', 'https://fr.openfoodfacts.org/images/products/306/832/012/0256/ingredients_fr.40.200.jpg', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean consectetur est a leo scelerisque, sed suscipit nisl euismod. Aliquam semper dui vitae neque lobortis egestas. ', 2.45, 20);

INSERT INTO transactions (user_id, total_bill, payment_mode, transaction_date) VALUES
    (1, 25.95, 'NFC', LOCALTIMESTAMP),
    (1, 23.95, 'NFC', '2021-12-01T15:43:00'),
    (2, 21.95, 'QR', '2021-11-28T18:11:00');

INSERT INTO cart_products (cart_id, product_id, quantity) VALUES
    (3, 1, 3),
    (3, 2, 1),
    (1, 1, 5);

INSERT INTO transaction_products (transaction_id, product_id, quantity) VALUES
    (2, 1, 1),
    (1, 3, 8),
    (2, 2, 4);
