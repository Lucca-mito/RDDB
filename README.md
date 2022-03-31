# RDRB
## Red Door Database
A database for management of Red Door Marketplace. 

To set up the database:
- First, create the database tables using setup.sql.
- Create functions and procedures using `source setup-routines.sql`. It is important that the procedures are set up before the data is loaded because some of the triggers act on the data to be loaded.
- Load the student, item, and worker data from the CSVs in the tables using `source load-data.sql`. This will also call the generate_order_data procedure to populate rd_order and order_item with fake order data.
- Load the authentication data with `source setup-passwords.sql` and `source grant-permissions.sql` (in whatever other).
- For students: use RDDB via `python app_student.py`. Log in with your RDDB username (not your UID) and password. For testing the application, we have created an RDDB account for two students, one for each meal plan:

| RDDB username | RDDB password | Student | UID | Plan|
| ----------------------------------------------------|
|jbutt | theflexer | James Butt | 1000 | flex|
|jdarakjy | theanytimer | James Butt | 1000 | flex|

- For 

To use the app, simply follow the onscreen instructions. Attempting to insert invalid data (e.g. )

/data
 - sample student dataset
 - sample worker dataset
 - Red Door food item dataset
