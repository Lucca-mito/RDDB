import sys
import mysql.connector
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = False

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
            sys.stderr('Could not connect to RDDB, please contact the database '
                       'administrator.')
        sys.exit(1)

def sql_query(sql, fetchone=False, modifies_db=False):
    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        if fetchone:
            result = cursor.fetchone()
        else:
            result = cursor.fetchall()

        if modifies_db:
            conn.commit()

        return result
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
        else:
            print("Sorry, we couldn't complete your request."
                       'Please contact the administrator for RDDB.')
        sys.exit(1)

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

def item_details():
    print()
    print("Enter the item name (or part of it). Enter q to cancel.")
    ans = prompt()

    if ans == 'q':
        return
    
    print()

    sql = "SELECT item_id, item_name, price, is_barcode, vegetarian, gluten_free, dairy_free FROM item WHERE item_name LIKE '%%%s%%';" % (ans, )

    rows = sql_query(sql)
    for row in rows:
        item_id, item_name, price, is_barcode, vegetarian, gluten_free, dairy_free = row

        barcode_indicator = '*' if is_barcode else ''

        dietary_indicators = []

        if vegetarian: dietary_indicators.append('v')
        if gluten_free: dietary_indicators.append('gf')
        if dairy_free: dietary_indicators.append('df')

        print(f'#{item_id}: {item_name} (${price}{barcode_indicator}) ' +
              ' '.join(dietary_indicators))

def place_order():
    print()
    print("What is the student's UID?")
    uid = prompt()

    sql_query('INSERT INTO rd_order(uid, worker_id) VALUES (%s, %s);' 
              % (uid, worker_id), modifies_db=True)

    (order_number,) = sql_query('SELECT MAX(order_number) FROM rd_order;', 
                                fetchone=True)

    print()
    print('Menu:')
    print('{:<32} {}'.format('Item name', 'Item ID'))
    print('-' * 40)
    for item_name, item_id in sql_query('SELECT item_name, item_id FROM item;'):
        print('{:<32} {}'.format(item_name, item_id))

    while True:
        print()
        print("Enter the ID of an item to add to this order, or enter p to place the order.")
        item_id = prompt()

        if item_id == 'p':
            break
        
        sql_query(
            'INSERT INTO order_item(order_number, item_id) VALUES (%s, %s);' 
            % (order_number, item_id), modifies_db=True)

        (item_name,) = sql_query(
            'SELECT item_name FROM item WHERE item_id = %s' % (item_id,), 
            fetchone=True)

        print(f'{item_name} added to order #{order_number}.')

    print(f'Order #{order_number} has been placed!')

def cancel_order():
    print()
    print('What is the UID of the student asking for a refund?')
    uid = prompt()

    sql = ('SELECT order_number, order_date, order_time FROM rd_order ' +
           'WHERE uid=%s' % (uid,))

    rows = sql_query(sql)
    n = len(rows)

    if n == 0:
        print('This student has not made any orders.')
        return

    print()
    print(f"This student has made {n} order{'s' if n > 1 else ''} at Red Door:")

    for row in rows:
        order_number, order_date, order_time = row
        print(f'Order #{order_number} on {order_date} at {order_time}')

    if n > 1:
        print()
        print('Cancel and refund which order?')
        order_number = prompt()
    else:
        order_number = rows[0][0]

    while True:
        print()
        print(f'Cancel order {order_number}? (y/n)')
        ans = prompt()

        if ans == 'y':
            sql_query('CALL sp_cancel_order(%s);' % (order_number, ), modifies_db=True)
            print(f'Order {order_number} canceled successfully.')
            break
        elif ans == 'n':
            print('Ok then')
            break
        else:
            print('Please enter y or n.')

def show_options():
    print()
    print('What would you like to do?')
    print('  (s) - search for an item and view details')
    print('  (p) - place an order')
    print('  (c) - cancel and refund an order')
    print('  (q) - quit')

    ans = prompt()

    if ans == 's':
        item_details()
    elif ans == 'p':
        place_order()
    elif ans == 'c':
        cancel_order()
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
