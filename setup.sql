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
    item_name   VARCHAR(50) NOT NULL UNIQUE,

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
    worker_id         INT UNSIGNED PRIMARY KEY,
    worker_first_name VARCHAR(50) NOT NULL,
    worker_last_name  VARCHAR(50) NOT NULL,
    hours_per_week    TINYINT UNSIGNED NOT NULL
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
    worker_id   INT UNSIGNED NOT NULL,

    FOREIGN KEY (uid) REFERENCES student(uid) 
     ON UPDATE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES worker(worker_id)
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

    -- The amount, in dollars, charged for that item. 
    -- Note that this is distinct from item.price: 
    -- 1. If the student is on anytime, the price_charged is zero unless the 
    --    order already contains an items of the same category.
    -- 2. Also, regardless of meal plan, we want a record of how much a student 
    --    was charged for an item at the time of purchase, but item.price may 
    --    change over time.
    amount_charged NUMERIC(4, 2) NOT NULL DEFAULT 0,

    FOREIGN KEY (order_number) REFERENCES rd_order(order_number)
                               ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (item_id) REFERENCES item(item_id)
                          ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE VIEW student_total_charges AS
    SELECT uid, SUM(amount_charged) total_charges
    FROM order_item NATURAL JOIN rd_order GROUP BY uid;

-- Create index on order date and time to make sorted or filtering on times 
-- easier. 
CREATE UNIQUE INDEX idx_order ON rd_order (order_date, order_time);

-- TODO: remove before submitting
SOURCE setup-routines.sql;
SOURCE load-data.sql;
CALL generate_order_data(1000);