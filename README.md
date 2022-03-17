# RDRB
## Red Door DataBase
A database for management of Red Door Marketplace and student dining plans. 

To set up the database:
- First, create the database tables using setup.sql
- Load the student, item, and worker data from the CSVs in the tables using load-data.sql 
- Create functions and procedures using setup-routines.sql
- Call the generate_order_data procedure to populate rd_order with fake order data (CALL generate_order_data(1000); -- example call)
-- order_item will be automatically updated as a result of the trigger


/data
 - sample student dataset
 - sample worker dataset
 - Red Door food item dataset
