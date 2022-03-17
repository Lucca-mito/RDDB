DROP FUNCTION IF EXISTS get_balance;
CREATE FUNCTION get_balance(uid INT UNSIGNED)
RETURNS INT UNSIGNED DETERMINISTIC
RETURN (SELECT balance FROM flex_student WHERE student.uid = uid);

DELIMITER !

/* Deletes the order from rd_order, which (via ON DELETE CASCADE) also deletes 
the entries of order_item associated with this order. The total charges and 
balance are in a view, so we don't need to do anything about them. */
DROP PROCEDURE IF EXISTS sp_cancel_order!
CREATE PROCEDURE sp_cancel_order(o_num INT UNSIGNED)
BEGIN
    DELETE FROM rd_order WHERE order_number = o_num;
END!

/* Whenever a student places an order: if the student is on anytime, check if 
it's been 30+ minutes since their last order. If not, cancel this order (by 
raising SQLSTATE 45000). */
/*
DROP TRIGGER IF EXISTS trg_before_new_order!
CREATE TRIGGER trg_before_new_order BEFORE INSERT ON order
FOR EACH ROW BEGIN

END!
*/

/* Whenever an order_item is added: 
1. Increase the order_total of the corresponding rd_order.
2. If the student is on anytime, check if the order doesn't contain multiple 
   items of the same category. If it does, cancel the order. */
DROP TRIGGER IF EXISTS trg_after_new_order_item!
CREATE TRIGGER trg_after_new_order_item AFTER INSERT ON order_item
FOR EACH ROW BEGIN
    DECLARE orderer_plan ENUM('flex', 'anytime');

    DECLARE curr_price NUMERIC(4, 2);

    -- Whether there are multiple items per category.
    DECLARE invalid BOOL;
    
    SELECT plan 
    FROM rd_order NATURAL JOIN student 
    WHERE order_number = NEW.order_number 
    INTO orderer_plan;

    IF orderer_plan = 'anytime' THEN
        SELECT MAX(item_count) > 1 FROM 
            (SELECT COUNT(*) item_count 
             FROM order_item NATURAL JOIN item 
             GROUP BY category) _
        INTO invalid;
        
        IF invalid THEN
            CALL sp_cancel_order(NEW.order_number);
        END IF;
    END IF;
END!

DELIMITER ;


-- A procedure which takes one int argument, the number of fake rows of orders
-- to add to rd_order, and selects random students with random cashiers, and 
-- a random number of items between 1 and 3 to order. 
DROP PROCEDURE IF EXISTS generate_order_data;
DELIMITER !
CREATE PROCEDURE generate_order_data(
    num_orders_to_add INT
)
BEGIN
  DECLARE i INT DEFAULT 0; -- keeps track of number of orders already created
  -- Randomly generated values for current order
  DECLARE i_uid INT;
  DECLARE i_cashier INT;
  DECLARE i_date_time TIME;
  DECLARE i_date DATE;
  DECLARE i_time TIME;
  DECLARE n INT; -- random number of items between 1 and 3 for order i 
  -- order id is automatically set, but is retrieved here because it is needed
  -- to add items to the order_item table
  DECLARE i_order_id INT; 
  -- Used to randomly pick items within order i 
  DECLARE j INT DEFAULT 0;
  DECLARE rand_item INT;

  -- Select random time for order
  WHILE i < num_orders_to_add DO
    SELECT DATE_FORMAT(
    from_unixtime(
        rand() * 
            (unix_timestamp('2021-9-20 8:00:00') - unix_timestamp('2022-3-16 22:00:00')) + 
            unix_timestamp('2022-3-16 22:00:00')
                  ), '%Y-%m-%d %H:%i:%s') AS d INTO i_date_time;
    SELECT TIME(i_date_time) INTO i_time;

    -- Select random date from the past 100 days
    SELECT CURRENT_DATE - INTERVAL FLOOR(RAND() * 100) DAY INTO i_date;

    -- Pick a random student for order
    SELECT uid FROM student ORDER BY RAND() LIMIT 1 INTO i_uid;

    -- Pick a random worker for order
    SELECT worker_id FROM worker ORDER BY RAND() LIMIT 1 INTO i_cashier;

    IF NOT EXISTS (SELECT * FROM 
    rd_order WHERE order_date = i_date AND order_time = i_time)
    THEN 
      -- Create the new order
      INSERT INTO rd_order (order_date, order_time, `uid`, worker_id) VALUES (
        i_date, i_time, i_uid, i_cashier);
      
      -- Retrieve order number
      SELECT order_number FROM rd_order WHERE order_date = i_date AND 
      order_time = i_time AND uid = i_uid AND worker_id = i_cashier INTO 
      i_order_id;

      -- Add order items
      -- Randomly pick between 1 and 3 items to order
      SELECT FLOOR(RAND()*(3-1)+1) INTO n;
      
      SET j = 0;
      WHILE j < n DO
        -- Pick a random item to order
        -- Assumes trigger on order_item works
        SELECT item_id FROM item ORDER BY RAND() LIMIT 1 INTO rand_item;
        INSERT INTO order_item(order_number, item_id) 
        VALUES (i_order_id, rand_item);
        SET j = j + 1;
      END WHILE; 
    END IF;

    SET i = i + 1;

  END WHILE;
END ! 
DELIMITER ;

-- If you want to test test function 
-- CALL generate_order_data(3);


