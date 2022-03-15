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

    -- "invalid" means items_in_category > 1
    DECLARE items_in_category TINYINT;
    
    SELECT plan 
    FROM rd_order NATURAL JOIN student 
    WHERE order_number = NEW.order_number 
    INTO orderer_plan;

    IF orderer_plan = 'anytime' THEN
        insert into debug values('order_item was ordered by an anytimer');
    END IF;
END!

DELIMITER ;