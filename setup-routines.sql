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
DROP PROCEDURE IF EXISTS sp_cancel_order!
CREATE PROCEDURE sp_cancel_order(o_num INT UNSIGNED)
BEGIN
    DELETE FROM rd_order WHERE order_number = o_num;
    -- TODO: decrease students.total_charges and, 
    -- if applicable, flex_student.balance
END!

/* Check if the new student chose the flex plan. 
If they did, add them to flex_student. */
DROP TRIGGER IF EXISTS trg_after_new_student!
CREATE TRIGGER trg_after_new_student AFTER INSERT ON student
FOR EACH ROW BEGIN
    IF NEW.plan = 'flex' THEN
        INSERT INTO flex_student(uid) VALUES (NEW.uid);
    END IF;
END!

/* Whenever a student places an order: if the student is on anytime, check if 
it's been 30+ minutes since their last order. If not, cancel this order (by 
raising SQLSTATE 45000). We don't have to change student.total_charges or 
flex_student.balance because
1. These fields haven't been changed yet: new orders add a row to rd_order 
    before they add a row to order_items, and only inserts into the letter 
    change student.total_charges and flex_student.balance.
2. The order_items will fail to go through (since they must reference rd_order, 
   which we will have deleted), so student.total_charges and 
   flex_student.balance will not be affected. */
/*DROP TRIGGER IF EXISTS trg_before_new_order!
CREATE TRIGGER trg_before_new_order BEFORE INSERT ON order
FOR EACH ROW BEGIN

END!*/

/* Whenever an order_item is added to an order: if the student is on flex, 
check if they have enough balance; and if the student is on anytime, check if 
the order doesn't contain multiple items of the same category. If the order is 
valid, increase student.total_charges and decrease flex_student.balance. If the 
order is invalid, delete the corresponding rd_order, and undo the changes to 
student.total_charges and flex_student.balance made by the previous order_items 
of the rd_order. */
DROP TRIGGER IF EXISTS trg_after_new_order_item!
CREATE TRIGGER trg_after_new_order_item AFTER INSERT ON order_item
FOR EACH ROW BEGIN
    DECLARE orderer_plan ENUM('flex', 'anytime');

    -- For flex students, "invalid" means order_total > curr_balance
    DECLARE curr_balance INT;
    DECLARE order_total INT;

    -- For anytime students, "invalid" means items_in_category > 1
    DECLARE items_in_category TINYINT;
    
    SELECT plan 
    FROM rd_order NATURAL JOIN student 
    WHERE order_number = NEW.order_number 
    INTO orderer_plan;

    IF plan = 'flex' THEN
        insert into debug values('order_item was ordered by a flex student');
        -- select get_balance(___) into curr_balance
        -- select ___ into order_total
        -- call sp_cancel_order
    ELSE
        insert into debug values('order_item was ordered by an anytime student');
    END IF;
END!

DELIMITER ;