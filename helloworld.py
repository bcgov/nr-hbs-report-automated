    """
    example of how to connect to an Oracle database using oracledb module.
    import oracledb

dsn = f"your_host:1521/your_service_name"

connection = oracledb.connect(
    user="your_username", password="your_password", dsn=dsn
)


    Returns:
        _type_: _description_
    """

import oracledb
import os


def connectdb():
    try:
        #oracledb.init_oracle_client(lib_dir='/opt/oracle/instantclient_19_8')
        connection = oracledb.connect(user='hr', password='hr', dsn='localhost/orclpdb')
        print("Connected to Oracle Database")
        return connection
    except oracledb.DatabaseError as e:
        print(f"Database connection error: {e}")
        return None
    
def get_ora_params():
    param_dict = {}
    env = 'TEST'
    param_dict['host'] = os.getenv(f'ORACLE_HOST_{env}')
    print(f"the host is: {param_dict['host']}")


print('hello world')
get_ora_params()