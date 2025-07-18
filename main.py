# main.py

from db_connection import get_connection

# Test database connection
test_conn = get_connection("test")
print("Test connection:", test_conn)
if test_conn:
    cursor = test_conn.cursor()
    cursor.execute("SELECT * FROM dual")
    for row in cursor:
        print("Test DB row:", row)
    test_conn.close()

# Production database connection
prod_conn = get_connection("prod")
if prod_conn:
    cursor = prod_conn.cursor()
    cursor.execute("SELECT * FROM dual")
    for row in cursor:
        print("Prod DB row:", row)
    prod_conn.close()
