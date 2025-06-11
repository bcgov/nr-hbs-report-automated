import pyodbc
import os
from dotenv import load_dotenv

load_dotenv()

def get_connection(env="test"):
    env = env.lower()

    if env == "test":
        user = os.getenv("TEST_DB_USER")
        password = os.getenv("TEST_DB_PASSWORD")
        dsn = os.getenv("TEST_DB_DSN")  # should be in host:port/service_name format
    elif env == "prod":
        user = os.getenv("PROD_DB_USER")
        password = os.getenv("PROD_DB_PASSWORD")
        dsn = os.getenv("PROD_DB_DSN")
    else:
        raise ValueError(f"Unknown environment: {env}")

    if not all([user, password, dsn]):
        raise EnvironmentError(f"Missing DB credentials for {env} environment")

    conn_str = (
        f"DRIVER={{Oracle in instantclient_19c}};"
        f"DBQ={dsn};"
        f"UID={user};"
        f"PWD={password};"
    )

    try:
        connection = pyodbc.connect(conn_str)
        print(f"✅ Connected to {env} database using pyodbc")
        return connection
    except Exception as e:
        print(f"❌ Failed to connect to {env} database via pyodbc:", e)
        return None
