DROP USER IF EXISTS 'admin'@'localhost';
CREATE USER 'admin'@'localhost' IDENTIFIED BY 
'wyhryf-kucSi4-nepbom-jocTyq-4iikms'; -- Admin must have a very secure password.
GRANT ALL PRIVILEGES ON rddb.* TO 'admin'@'localhost';

DROP USER IF EXISTS 'staff'@'localhost';
CREATE USER 'staff'@'localhost' IDENTIFIED BY 'vAjmu-ziwqu-8hefr';
GRANT SELECT, INSERT, EXECUTE ON rddb.* TO 'staff'@'localhost';

/* Orders are placed by the staff, not the students. This simplifies matters greatly, as 
1. We only need one database user to represent all students. 
2. There is no need for a (secure) password for this database user. 
3. Students only need the SELECT privilege. (In practice, however, we must also 
   grant the EXECUTE privilege so that the student application can call 
   authentication UDFs.) */
DROP USER IF EXISTS 'student'@'localhost';
CREATE USER 'student'@'localhost' IDENTIFIED BY 'student';
GRANT SELECT, EXECUTE ON rddb.* TO 'student'@'localhost';

FLUSH PRIVILEGES;