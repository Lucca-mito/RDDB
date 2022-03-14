DROP TABLE IF EXISTS student;
CREATE TABLE student(
    uid           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(100),
    plan          ENUM('anytime', 'flex') NOT NULL DEFAULT 'flex',
    total_charges INT UNSIGNED NOT NULL DEFAULT 0
);

DROP TABLE IF EXISTS flex_student; 
CREATE TABLE flex_student(
    uid     INT UNSIGNED PRIMARY KEY,
    balance INT UNSIGNED NOT NULL DEFAULT 0,

    FOREIGN KEY (uid) REFERENCES student(uid)
);

DROP TABLE IF EXISTS item; 
CREATE TABLE item(
    item_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT
);

-- `order` is a reserved keyword, so we use `rd_order` instead
DROP TABLE IF EXISTS rd_order;
CREATE TABLE rd_order(
    order_number INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_date   DATE NOT NULL,
    order_time   TIME NOT NULL,
    uid          INT UNSIGNED NOT NULL,
    cashier_id   INT UNSIGNED NOT NULL,

    FOREIGN KEY (uid) REFERENCES student(uid)
);

DROP TABLE IF EXISTS order_item;
CREATE TABLE order_item(
    order_number INT UNSIGNED,
    item_id      INT UNSIGNED,

    FOREIGN KEY (order_number) REFERENCES rd_order(order_number)
                               ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
)