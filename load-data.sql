LOAD DATA LOCAL INFILE 'data/red_door_items.csv' INTO TABLE item
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/students.csv' INTO TABLE student
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/workers.csv' INTO TABLE worker
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

INSERT INTO rd_order(order_number, uid, worker_id) VALUES (1, 1499, 1);

INSERT INTO order_item(order_number, item_id) 
VALUES (1, 1001), (1, 3004), (1, 3004), (1, 4073);

CALL generate_order_data(1000);