# RDRB
## Red Door Database
A database for management of Red Door Marketplace. 

To set up the database:
- First, create the database tables using setup.sql.
- Create functions and procedures using `source setup-routines.sql`. It is important that the procedures are set up before the data is loaded because some of the triggers act on the data to be loaded.
- Load the student, item, and worker data from the CSVs in the tables using `source load-data.sql`. This will also call the generate_order_data procedure to populate rd_order and order_item with fake order data.
- Load the authentication data with `source setup-passwords.sql`.

/data
 - sample student dataset
 - sample worker dataset
 - Red Door food item dataset
