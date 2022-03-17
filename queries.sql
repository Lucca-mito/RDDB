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
GROUP BY order_date) t NATURAL JOIN spending;

-- Which hour was busiest and what percentage of total orders occurred in that 
-- hour? 
-- WITH hourly_orders AS (
--   SELECT HOUR(order_time) as hour_of_day, COUNT(order_number) AS num_orders 
--   FROM rd_order GROUP BY HOUR(order_time)
-- )
-- SELECT hour_of_day, MAX(order_number)
-- ;


-- Compute the largest different in the remaining declining balance for all 
-- flex students. 

-- Student x is dropping out, remove them from the query. 
-- The price of beef has recently increased, update the value of beef and update
-- 