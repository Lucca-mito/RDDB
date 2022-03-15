-- INSERT INTO student(uid, first_name, last_name, plan) VALUES
--     (1, 'Emily', 'Zheng', 'flex'),
--     (2, 'Lucca', 'de Mello', 'anytime'),
--     (3, 'Tony', 'Liu', 'flex'),
--     (4, 'Tony', 'Poo', 'anytime');

-- INSERT INTO item(item_id, item_name, category) VALUES
--     (1, 'salmon avocado toast', 'meal');

-- INSERT INTO worker(first_name, last_name, hours_per_week) VALUES
--     (1, 'Melissa', 'Hovik', 168);

-- INSERT INTO rd_order(uid, cashier_id) VALUES 
--     (1, 1),
--     (2, 1);


LOAD DATA LOCAL INFILE 'red_door_items.csv' INTO TABLE item
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'students.csv' INTO TABLE student
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'workers.csv' INTO TABLE worker
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
