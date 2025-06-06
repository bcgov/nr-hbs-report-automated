from datetime import datetime
import os
import pandas as pd
from db_connection import get_connection
import sys

# Get environment argument: default to "test"
env = sys.argv[1] if len(sys.argv) > 1 else "test"
env = env.lower()

# Get current year and month as yyyymm
yyyymm = datetime.now().strftime("%Y%m")

# Define output directory
output_dir = r"C:\Users\touyang\Desktop\timberwest_report"

# Create the folder if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Create full file path
filename = os.path.join(output_dir, f"client_{env}_{yyyymm}.xlsx")

# Connect to the specified environment
conn = get_connection(env=env)

# Your query
query = """
SELECT 
    fc.client_number AS ClientNum,  
    DECODE(FC.CLIENT_TYPE_CODE, 'I', NULL, FC.CLIENT_NAME) AS CLIENTNAME
FROM Forest_CLIENT FC
"""

# Run query and load into DataFrame
df = pd.read_sql(query, conn)

# Save Excel file
df.to_excel(filename, index=False)

print(f"File saved as: {filename}")

# Close connection
conn.close()
