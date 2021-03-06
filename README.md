# RDDB
## Red Door Database
A database and application for management of the Red Door Marketplace at Caltech. 

To set up the database:
- First, create the database tables using setup.sql.
- Create functions and procedures using `source setup-routines.sql`. It is important that the procedures are set up before the data is loaded because some of the triggers act on the data to be loaded.
- Load the student, item, and worker data from the CSVs in the tables using `source load-data.sql`. This will also call the `generate_order_data` procedure to populate rd_order and order_item with fake order data.
- Load the authentication data with `source setup-passwords.sql` and `source grant-permissions.sql` (in whatever other).
- For students: use RDDB via `python app_student.py`. Log in with your RDDB username (not your UID) and password. For testing the application, we have created an RDDB account for two students, one for each meal plan:

| RDDB username | RDDB password | Student    | UID  | Plan    |
|---------------|---------------|------------|------|---------|
| jbutt         | theflexer     | James Butt | 1000 | flex    |
| jdarakjy      | theanytimer   | James Butt | 1000 | anytime |

- For staff: use RDDB via `python app_staff.py`. Log in with your RDDB username (not your worker_id) and password. For testing the application, we have created an RDDB account for worker Post Malone (username: pmalone, password: rockstar), whose worker_id is 1.

To use the app, simply follow the onscreen instructions. If the user attempts to insert invalid data (e.g. a student tries to find the #RedDoorFave of a nonexistent student, or a worker tries to add a nonexistent item to an order), the error is gracefully suppressed and the user is redirected to the main menu.

The data on students, workers, and orders used in this application is entirely synthetic. The student names were generated by randomly combining first names and last names taken from a list on the web (we don't remember from where). The workers were invented manually. The items are a subset of the actual Red Door menu, though the prices were assigned at random. The orders and their contents are generated using the aforementioned `generate_order_data` procedure.

/data
 - sample student dataset: `students.csv`
 - sample worker dataset: `workers.csv`
 - Red Door food item dataset: `red_door_items.csv`
