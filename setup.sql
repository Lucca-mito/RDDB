DROP TABLE IF EXISTS order_item, 
                     rd_order, 
                     worker, 
                     item, 
                     flex_student, 
                     student, 
                     debug;

-- For debugging purposes.
CREATE TABLE debug(
    stdout VARCHAR(200)
);

CREATE TABLE student(
    uid        INT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    plan       ENUM('flex', 'anytime') NOT NULL DEFAULT 'flex'
);

CREATE OR REPLACE VIEW student_total_charges AS
    SELECT uid, SUM(order_total) total_charges
    FROM rd_order NATURAL JOIN stduent GROUP BY uid;

CREATE OR REPLACE VIEW flex_student_balance AS
    SELECT uid, GREATEST(525 - total_charges, 0) balance
    FROM student NATURAL JOIN student_total_charges WHERE plan = 'flex';

CREATE TABLE item(
    item_id     INT UNSIGNED PRIMARY KEY,
    item_name   VARCHAR(50) NOT NULL,
    price       NUMERIC(4, 2) NOT NULL,
    is_barcode  BOOL NOT NULL DEFAULT FALSE,
    vegetarian  BOOL NOT NULL DEFAULT FALSE,
    gluten_free BOOL NOT NULL DEFAULT FALSE,
    dairy_free  BOOL NOT NULL DEFAULT FALSE,
    category    ENUM('meal', 'pastry', 'drink', 'other') 
                NOT NULL DEFAULT 'other'
);

CREATE TABLE worker(
    worker_id      INT UNSIGNED PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    hours_per_week TINYINT UNSIGNED NOT NULL
);

-- `order` is a reserved keyword, so we use `rd_order` instead
CREATE TABLE rd_order(
    order_number INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_date   DATE NOT NULL DEFAULT (CURDATE()),
    order_time   TIME NOT NULL DEFAULT (CURRENT_TIME()),
    uid          INT UNSIGNED NOT NULL,
    cashier_id   INT UNSIGNED NOT NULL,
    order_total  INT UNSIGNED NOT NULL DEFAULT 0,

    FOREIGN KEY (uid) REFERENCES student(uid),
    FOREIGN KEY (cashier_id) REFERENCES worker(worker_id)
);

CREATE TABLE order_item(
    order_number INT UNSIGNED,
    item_id      INT UNSIGNED,

    FOREIGN KEY (order_number) REFERENCES rd_order(order_number)
                               ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

-- TODO: remove before submitting
SOURCE load-data.sql;