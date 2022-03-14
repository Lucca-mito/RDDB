CREATE TABLE student(
    uid INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(100),
    plan ENUM('anytime', 'flex') NOT NULL,
    total_charges INT NOT NULL -- why do we have total_charges again?
);

CREATE TABLE flex_student(
    uid INT UNSIGNED PRIMARY KEY,
    FOREIGN KEY uid REFERENCES student(uid),

    balance INT UNSIGNED NOT NULL
);