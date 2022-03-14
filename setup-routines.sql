DROP FUNCTION IF EXISTS get_balance;
CREATE FUNCTION get_balance(uid INT UNSIGNED)
RETURNS INT UNSIGNED DETERMINISTIC
RETURN (SELECT balance FROM flex_student WHERE student.uid = uid);

DELIMITER !

/* 
1. Deletes the order from rd_order, which (via ON DELETE CASCADE) also 
   deletes the entreis of order_item associated with this order.
2. Decreases student.total_charges.
3. If the student is on flex, increases flex_student.balance. */
DROP PROCEDURE IF EXISTS sp_cancel_order;

-- TODO: create trigger for adding flex students

-- TODO: create trigger after insert on rd_order to check if it's been 30+ minutes (if student is on anytime)

/* Whenever an order_item is added to an order: if the student is on flex, 
check if they have enough balance; and if the student is on anytime, check if 
the order doesn't contain multiple items of the same category. If the order is 
valid, increase student.total_charges and decrease flex_student.balance. If the 
order is invalid, delete the corresponding rd_order and throw an error. The 
error will cause the database to rollback to how it was before the insert, 
undoing the changes to student.total_charges and flex_student.balance. */
DROP TRIGGER IF EXISTS trg_after_new_order_item!
CREATE TRIGGER trg_after_new_order_item AFTER INSERT ON order_item
FOR EACH ROW BEGIN
    DECLARE orderer_plan ENUM('flex', 'anytime');

    -- For flex students, "invalid" means order_total > curr_balance
    DECLARE curr_balance INT;
    DECLARE order_total INT;

    -- For anytime students, "invalid" means num_of_category > 1
    DECLARE num_of_category TINYINT;
    
    SELECT plan 
    FROM rd_order NATURAL JOIN student 
    WHERE order_number = NEW.order_number 
    INTO orderer_plan;

    IF plan = 'flex' THEN
        update flex_student set balance = balance + 1; -- for debugging
        -- select get_balance(___) into curr_balance
        -- select ___ into order_total
        -- call sp_cancel_order
    ELSE
        update flex_student set balance = orderer_plan; -- for debugging
    END IF;

    -- SELECT get_balance(___) INTO curr_balance;
    /* IF ___ THEN
        SIGNAL SQLSTATE '45000' 
        -- TODO: add student name and balance to message text
        SET MESSAGE_TEXT = 'student does not have enough balance');
    END IF; */
END!

DELIMITER ;