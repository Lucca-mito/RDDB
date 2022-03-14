INSERT INTO student(first_name, last_name, plan) VALUES
    ('Emily', 'Zheng', 'flex'),
    ('Lucca', 'de Mello', 'anytime'),
    ('Tony', 'Liu', 'flex'),
    ('Tony', 'Poo', 'anytime');

-- TODO: remove once we add the trg_add_flex_student trigger.
INSERT INTO flex_student(uid) VALUES (1), (3);

INSERT INTO item(item_name, category) VALUES
    ('salmon avocado toast', 'meal');

INSERT INTO worker(first_name, last_name, hours_per_week) VALUES
    ('Melissa', 'Hovik', 168);

INSERT INTO rd_order(order_date, order_time, uid, cashier_id) VALUES 
    (NOW(), NOW(), 1, 1),
    (NOW(), NOW(), 2, 1);