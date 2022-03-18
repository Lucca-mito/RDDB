-- Which students on anytime are spending the most each day? 
-- Return the student ID, date, and amount spent sorted by
-- date in ascending order 
WITH spending AS
  (SELECT uid, order_date, SUM(amount_charged) AS total_spending 
   FROM order_item NATURAL JOIN rd_order NATURAL JOIN student 
   WHERE plan = 'anytime' 
   GROUP BY uid, order_date)
SELECT uid, order_date AS date, max_spending 
FROM (SELECT order_date, MAX(total_spending) AS max_spending FROM spending
GROUP BY order_date) t NATURAL JOIN spending ORDER BY order_date ASC;

-- Which hour was busiest and how many orders? 
WITH hourly_orders AS
  (SELECT HOUR(order_time) as hour_of_day, COUNT(order_number) AS num_orders 
   FROM rd_order GROUP BY HOUR(order_time)),
most_orders AS 
  (SELECT MAX(num_orders) as num_orders FROM hourly_orders)
SELECT hour_of_day, num_orders AS max_orders FROM 
  (SELECT * FROM most_orders NATURAL JOIN hourly_orders) t;

-- A student wants to get a list of all vegan options for ease 
-- sorted by popularity (descending). 
SELECT item_id, item_name, COUNT(*) AS times_ordered
FROM order_item NATURAL JOIN item
WHERE vegetarian = TRUE AND dairy_free = TRUE
GROUP BY item_id, item_name
ORDER BY times_ordered DESC;

-- Calculate the total remaining balance for all students on the flex plan
-- Recall that students start with a balance of $525.00
SELECT uid, GREATEST(525 - total_charges, 0) AS balance
FROM student_total_charges NATURAL JOIN student WHERE plan = 'flex';

-- Four figures: find anytime students that have somehow managed to spend $1K 
-- or more at Red Door. Since anytime students only pay for barcode items and 
-- items whose category appears multiple times in the order, this will almost 
-- certiainly return the empty set.
SELECT uid, first_name, last_name, total_charges, plan
FROM student NATURAL JOIN student_total_charges
WHERE plan = 'anytime';
AND total_charges >= 1000