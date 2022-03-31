import sys
import mysql.connector
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = True

# The ID of the Red Door staff member currently logged in.
worker_id = None

# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='staff',
          port='3306',
          password='vAjmu-ziwqu-8hefr',
          database='rddb'
        )
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the database '
            'administrator for RDDB.')
        sys.exit(1)

def sql_query(sql, fetchone=False):
    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        if fetchone:
            return cursor.fetchone()
        else:
            return cursor.fetchall()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, please contact the database administrator for RDDB.')

# ----------------------------------------------------------------------
# Functions for Logging Staff In
# ----------------------------------------------------------------------
def login():
    # print('Login')
    # username = input('Username: ')
    # password = input('Password: ')

    # sql_query('SELECT authenticate()')

    global worker_id
    worker_id = 1

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def prompt():
    return input('>>> ')

def get_item_id():
    print()
    print("Enter the item name (or part of it). Enter q to cancel.")
    ans = prompt()

    if ans == 'q':
        return
    
    print()

    sql = "SELECT item_name, item_id FROM item WHERE item_name LIKE '%%%s%%';" % (ans, )

    rows = sql_query(sql)
    for row in rows:
        item_name, item_id = row
        print(f'{item_name}: {item_id}')

def place_order():
    print()
    print("What is the student's UID?")
    uid = prompt()

    sql_query('INSERT INTO rd_order(uid, worker_id) VALUES (%s, %s);' 
              % (uid, worker_id))

    (order_number,) = sql_query('SELECT MAX(order_number) FROM rd_order;', 
                                fetchone=True)

    while True:
        print()
        print("Enter the ID of an item to add to this order, or enter p to place the order.")
        item_id = prompt()

        if item_id == 'p':
            break
        
        sql_query(
            'INSERT INTO order_item(order_number, item_id) VALUES (%s, %s);' 
            % (order_number, item_id))

    print(f'Order #{order_number} has been placed!')

def show_options():
    print()
    print('What would you like to do?')
    print('  (i) - find the id of an item')
    print('  (p) - place an order')
    print('  (q) - quit')

    ans = prompt()

    if ans == 'i':
        get_item_id()
    elif ans == 'p':
        place_order()
    elif ans == 'q':
        quit_ui()
    else:
        print('Please enter one of the characters shown in parantheses.')

    show_options()

def quit_ui():
    print('Thank you for being a part of the Red Door family!')
    print()
    exit()

def main():
    login()
    show_options()

if __name__ == '__main__':
    conn = get_conn()
    main()
