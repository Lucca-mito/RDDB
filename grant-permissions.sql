DROP USER IF EXISTS 'admin'@'localhost';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 
'wyhryf-kucSi4-nepbom-jocTyq-4iikms'; -- Admin must have a very secure password.
GRANT ALL PRIVILEGES ON rddb.* TO 'admin'@'localhost';

DROP USER IF EXISTS 'staff'@'localhost';
CREATE USER 'staff'@'localhost' IDENTIFIED BY 'vAjmu-ziwqu-8hefr';
GRANT SELECT, INSERT, EXECUTE ON rddb.* TO 'staff'@'localhost';

/* Orders are placed by the staff, not the students. Students  only need the 
SELECT privilege. This simplifies matters greatly, as we only need one database 
user to represent all students. It also means that there is 
no need for a (secure) password for this database user. */
DROP USER IF EXISTS 'student'@'localhost';
CREATE USER 'student'@'localhost' IDENTIFIED BY 'student';
GRANT SELECT ON rddb.* TO 'student'@'localhost';

FLUSH PRIVILEGES;