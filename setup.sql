DROP TABLE IF EXISTS order_item, 
                     rd_order, 
                     worker, 
                     item, 
                     student, 
                     debug;

-- For debugging purposes.
CREATE TABLE debug(
    stdout VARCHAR(200)
);

/*
 * This table stores information about students on a Dining Plan eligible to
 * make purchases at Red Door. 
 */
CREATE TABLE student(
    uid        INT UNSIGNED PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    plan       ENUM('flex', 'anytime') NOT NULL DEFAULT 'flex'
);

/*
 * This table stores information about all food items available for purchase.
 */
CREATE TABLE item(
    item_id     INT UNSIGNED PRIMARY KEY,
    item_name   VARCHAR(50) NOT NULL,
    -- If an item is bar-coded, it cannot be purchased by anytime students as 
    -- part of their meal plan. 
    is_barcode  BOOL NOT NULL DEFAULT FALSE,
    vegetarian  BOOL NOT NULL DEFAULT FALSE,
    gluten_free BOOL NOT NULL DEFAULT FALSE,
    dairy_free  BOOL NOT NULL DEFAULT FALSE,
    -- Anytime students can only buy at max one item of each category in one
    -- order. 
    category    ENUM('meal', 'pastry', 'drink', 'other') 
                NOT NULL DEFAULT 'other',
    price       NUMERIC(4, 2) NOT NULL
);

/*
 * This table stores information about all Red Door employees who might work
 * the cashier counter.
 */
CREATE TABLE worker(
    worker_id      INT UNSIGNED PRIMARY KEY,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    hours_per_week TINYINT UNSIGNED NOT NULL
);

/*
 * This table stores information about all orders made at Red Door. Each row
 * represents the information that would be printed out on one receipt.
 */
CREATE TABLE rd_order(
    -- Order number is called out when orders are ready for pick up. 
    order_number INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    order_date   DATE NOT NULL DEFAULT (CURDATE()),
    order_time   TIME NOT NULL DEFAULT (CURRENT_TIME()),
    -- The UID of the purchaser.
    uid          INT UNSIGNED NOT NULL,
    -- The id of the cashier who served the order.
    cashier_id   INT UNSIGNED NOT NULL,
    order_total  INT UNSIGNED NOT NULL DEFAULT 0,

    FOREIGN KEY (uid) REFERENCES student(uid) 
     ON UPDATE CASCADE,
    FOREIGN KEY (cashier_id) REFERENCES worker(worker_id)
     ON UPDATE CASCADE
);

/*
 * This table stores information about individual items purchased. Each row
 * corresponds to a single item in a single order.
 */
CREATE TABLE order_item(
    -- The id of the order to which the purchased item belonged.
    order_number INT UNSIGNED,
    -- The id of the actual item purchased.
    item_id      INT UNSIGNED,

    FOREIGN KEY (order_number) REFERENCES rd_order(order_number)
                                ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(item_id)
                                ON UPDATE CASCADE
);

CREATE OR REPLACE VIEW student_total_charges AS
    SELECT uid, SUM(order_total) total_charges
    FROM rd_order GROUP BY uid;

CREATE OR REPLACE VIEW flex_student_balance AS
    SELECT uid, GREATEST(525 - total_charges, 0) balance
    FROM student_total_charges NATURAL JOIN student WHERE plan = 'flex';

-- Create index on order date and time to make sorted or filtering on times 
-- easier. 
CREATE UNIQUE INDEX idx_order ON rd_order (order_date, order_time);

-- TODO: remove before submitting
SOURCE load-data.sql;
