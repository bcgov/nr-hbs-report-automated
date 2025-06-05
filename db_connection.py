# db_connection.py

import oracledb
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


def get_connection(env="test"):
    if env == "test":
        user = os.getenv("TEST_DB_USER")
        password = os.getenv("TEST_DB_PASSWORD")
        dsn = os.getenv("TEST_DB_DSN")
    elif env == "prod":
        user = os.getenv("PROD_DB_USER")
        password = os.getenv("PROD_DB_PASSWORD")
        dsn = os.getenv("PROD_DB_DSN")
    else:
        raise ValueError(f"Unknown environment: {env}")

    try:
        connection = oracledb.connect(
            user=user,
            password=password,
            dsn=dsn
        )
        print(f"✅ Connected to {env} database")
        return connection
    except Exception as e:
        print(f"❌ Failed to connect to {env} database:", e)
        return None