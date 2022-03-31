import sys
import mysql.connector
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = True

# The UID of the Caltech student currently logged in.
uid = None

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
          user='student',
          port='3306',
          password='student',
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
            sys.stderr('Sorry, we are unable to complete your request at this'
            'time. Please contact the RDDB customer support:\n'
            'rddbsupport@caltech.edu.')

def request_menu(where_clause):
    sql = ('SELECT item_name, price, is_barcode, COUNT(*) popularity ' +
           'FROM order_item NATURAL JOIN item ' + 
           where_clause +
           ' GROUP BY item_name, price, is_barcode ORDER BY popularity DESC;')

    print(' ' * 33 + '* = barcode')
    for row in sql_query(sql):
        item_name, price, is_barcode, _ = row

        item_name += ':'
        barcode_indicator = '*' if is_barcode else ''

        print('{:<32} ${}{}'.format(item_name, price, barcode_indicator))

# ----------------------------------------------------------------------
# Functions for Logging Users In
# ----------------------------------------------------------------------
def login():
    # print('Login')
    # username = input('Username: ')
    # password = input('Password: ')

    # sql_query('')

    global uid
    uid = 1000

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def prompt():
    return input('>>> ')

def browse_menu():
    where_clause = ''

    print()
    print('What are you looking for?')
    print('  (a) - show all items')
    print('  (b) - show all non-barcode items')
    print('  (m) - show meals')
    print('  (p) - show pastries')
    print('  (d) - show drinks')
    print('  (q) - back to main menu')

    ans1 = prompt()
    if ans1 == 'a':
        pass
    elif ans1 == 'b':
        where_clause = 'WHERE is_barcode=FALSE'
    elif ans1 == 'm':
        where_clause = "WHERE category='meal'"
    elif ans1 == 'p':
        where_clause = "WHERE category='pastry'"
    elif ans1 == 'd':
        where_clause = "WHERE category='drink'"
    elif ans1 == 'q':
        return
    else:
        print('Please enter one of the characters shown in parantheses.')
        browse_menu()

    print()
    print('Any dietary restrictions?')
    print('  (n) - no')
    print('  (g) - only show gluten-free items')
    print('  (d) - only show dairy-free items')
    print('  (v) - only show vegetarian items')
    print('  (V) - only show vegan items')

    ans2 = prompt()
    if ans2 != 'n':
        if ans1 == 'a':
            where_clause = 'WHERE '
        else:
            where_clause += ' AND '

    if ans2 == 'g':
        where_clause += 'gluten_free=TRUE'
    elif ans2 == 'd':
        where_clause += 'dairy_free=TRUE'
    elif ans2 == 'v':
        where_clause += 'vegetarian=TRUE'
    elif ans2 == 'V':
        where_clause += 'dairy_free=TRUE AND vegetarian=TRUE'

    request_menu(where_clause)

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

def view_order(order_number):
    print()

    sql = ('SELECT item_name, amount_charged FROM order_item NATURAL JOIN item '
        + f'WHERE order_number = %s' % (order_number,))

    for row in sql_query(sql):
        item_name, amount_charged = row

        if amount_charged > 0:
            price_annotation = f' for ${amount_charged}'
        else:
            price_annotation = ', courtesy of Anytime'
        
        print(item_name + price_annotation)

def view_order_history():
    print()

    sql = ('SELECT order_number, order_date, order_time FROM rd_order ' +
           'WHERE uid=%s' % (uid,))

    rows = sql_query(sql)
    n = len(rows)

    if n == 0:
        print('No orders to display.'
              'What are you waiting for? Red Door awaits.')
        return

    print()
    print(f"You've made {n} order{'s' if n > 1 else ''} at Red Door:")
    for row in rows:
        order_number, order_date, order_time = row

        print(f'Order #{order_number} on {order_date} at {order_time}')

    if n == 1:
        view_order(rows[0][0])
    else:
        print()
        print('Which order would you like to view?')
        view_order(prompt())

def view_favorite():
    print()
    print('Please enter their UID.')
    uid = prompt()

    sql = 'SELECT first_name, last_name FROM student WHERE uid = %s' % (uid, )
    first_name, last_name = sql_query(sql, fetchone=True)

    sql = ('SELECT item_name, COUNT(*) times_ordered ' +
           'FROM order_item ' +
           'NATURAL JOIN rd_order NATURAL JOIN item NATURAL JOIN student ' +
           'WHERE uid=%s ' % (uid,) +
           'GROUP BY item_name ORDER BY times_ordered DESC LIMIT 1;')

    item_name, times_ordered = sql_query(sql, fetchone=True)

    print(f'{first_name} {last_name} has ordered the {item_name} ' + 
          f'{times_ordered} time' + ('s.' if times_ordered > 1 else '.'))

def check_charges():
    sql = ('SELECT plan, total_charges ' +
           'FROM student_total_charges NATURAL JOIN student ' +
           'WHERE uid=%s;' % (uid, ))

    plan, total_charges = sql_query(sql, fetchone=True)

    print()
    print(f"You're on the {plan} plan, and you've been charged ${total_charges} in total.")

    if plan == 'flex':
        print(f'You have ${max(0, 525 - total_charges)} left in your flex balance.')

def show_options():
    print()
    print('What would you like to do?')
    print('  (m) - browse the menu')
    print('  (s) - search for an item and view details')
    print('  (h) - view your order history')
    print("  (f) - view someone's #RedDoorFave")
    print('  (c) - check your charges and balance')
    print('  (q) - quit')

    ans = prompt()
    
    if ans == 'm':
        browse_menu()
    elif ans == 's':
        item_details()
    elif ans == 'h':
        view_order_history()
    elif ans == 'q':
        quit_ui()
    elif ans == 'c':
        check_charges()
    elif ans == 'f':
        view_favorite()
    else:
        print()
        print('Please enter one of the characters shown in parantheses.')

    show_options()

def quit_ui():
    print('Thank you for choosing Red Door! :)')
    print()
    exit()

def main():
    login()
    show_options()

if __name__ == '__main__':
    conn = get_conn()
    main()
