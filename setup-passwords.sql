-- File for Password Management section of Final Project

-- (Provided) This function generates a specified number of characters for 
-- using as a salt in passwords.
DELIMITER !
DROP FUNCTION IF EXISTS make_salt!
CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) NO SQL
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- Provided (you may modify if you choose)
-- This table holds information for authenticating users based on
-- a password.  Passwords are not stored plaintext so that they
-- cannot be used by people that shouldn't have them.
-- You may extend that table to include an is_admin or role attribute if you 
-- have admin or other roles for users in your application 
-- (e.g. store managers, data managers, etc.)
DROP TABLE IF EXISTS user_info;
CREATE TABLE user_info (
    -- Usernames are up to 20 characters.
    username VARCHAR(20) PRIMARY KEY,

    -- The UID (for students) or the worker_id (for workers)
    id INT UNSIGNED NOT NULL,

    -- Salt will be 8 characters all the time, so we can make this 8.
    salt CHAR(8) NOT NULL,

    -- We use SHA-2 with 256-bit hashes.  MySQL returns the hash
    -- value as a hexadecimal string, which means that each byte is
    -- represented as 2 characters.  Thus, 256 / 8 * 2 = 64.
    -- We can use BINARY or CHAR here; BINARY simply has a different
    -- definition for comparison/sorting than CHAR.
    password_hash BINARY(64) NOT NULL,

    -- Whether the user is part of Red Door staff, or just a student.
    is_staff BOOL
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DELIMITER !
DROP PROCEDURE IF EXISTS sp_add_user!
CREATE PROCEDURE sp_add_user
  (new_username VARCHAR(20), id INT, password VARCHAR(20), is_staff BOOL)
BEGIN
  DECLARE salt CHAR(8);
  SELECT make_salt(8) INTO salt;

  INSERT INTO user_info 
  VALUES (new_username, 
          id, 
          salt, 
          SHA2(CONCAT(salt, password), 256), 
          is_staff);
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DROP FUNCTION IF EXISTS authenticate;
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
RETURN
  (SELECT COUNT(*) > 0 FROM user_info 
   WHERE user_info.username = username 
   AND password_hash = SHA2(CONCAT(salt, password), 256));

DROP FUNCTION IF EXISTS get_role;
CREATE FUNCTION get_role(username VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
RETURN
  (SELECT is_staff FROM user_info WHERE user_info.username = username);

DROP FUNCTION IF EXISTS get_id;
CREATE FUNCTION get_id(username VARCHAR(20))
RETURNS INT UNSIGNED DETERMINISTIC
RETURN
  (SELECT id FROM user_info WHERE user_info.username = username);

-- [Problem 1c]
-- Add at least two users into your user_info table so that when we run this 
-- file, we will have examples users in the database.
CALL sp_add_user('jbutt', 1000, 'theflexer', FALSE);
CALL sp_add_user('jdarakjy', 1001, 'theanytimer', FALSE);
CALL sp_add_user('pmalone', 1, 'rockstar', TRUE);

-- [Problem 1d]
-- Optional: Create a procedure sp_change_password to generate a new salt and change the given
-- user's password to the given password (after salting and hashing)
