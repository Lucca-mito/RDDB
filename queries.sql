-- Which students on the anytime are making the greatest number 
-- of orders each day? Return the student ID, date, and amount spent sorted by
-- date in ascending order 
WITH spending AS (
  SELECT uid, order_date, SUM(price) AS total_spending 
  FROM order_item NATURAL JOIN item NATURAL JOIN rd_order 
  NATURAL JOIN student WHERE plan = 'anytime' GROUP BY uid, order_date  
)
SELECT uid, order_date AS date, total_spending AS max_spending 
FROM (SELECT order_date, MAX(total_spending) AS total_spending FROM spending
GROUP BY order_date) t NATURAL JOIN spending ORDER BY order_date ASC;

-- Which hour was busiest and how many orders? 
WITH hourly_orders AS (
  SELECT HOUR(order_time) as hour_of_day, COUNT(order_number) AS num_orders 
  FROM rd_order GROUP BY HOUR(order_time)
), most_orders AS (
  SELECT MAX(num_orders) as num_orders FROM hourly_orders 
)
  SELECT hour_of_day, num_orders AS max_orders FROM 
  (SELECT * FROM most_orders NATURAL JOIN hourly_orders) t
;

-- A student wants to get a list of all vegan options for ease 
-- sorted by popularity (descending). 
WITH vegan_items AS (
  SELECT item_id, item_name FROM item 
  WHERE vegetarian = TRUE AND dairy_free = TRUE
)
SELECT item_id, item_name, count(*) AS times_ordered 
FROM order_item NATURAL JOIN vegan_items 
WHERE item_id IN (SELECT item_id FROM vegan_items)
GROUP BY item_id, item_name ORDER BY times_ordered DESC
;

-- Calculate the total remaining balance for all students on the flex plan
-- Recall that students start with a balance of $525.00
SELECT uid, first_name, last_name, 525 - SUM(order_total) AS remaining_balance 
FROM rd_order NATURAL JOIN student 
WHERE plan = 'flex' GROUP BY uid, first_name, last_name;
