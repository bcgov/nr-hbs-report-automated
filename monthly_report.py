import pandas as pd
import sys
import os
from datetime import datetime
import calendar
import re
from openpyxl import Workbook
import pyodbc
import getpass

# --- CONFIGURATION ---
yyyymm = datetime.now().strftime("%Y%m")
now = datetime.now()

username = os.getlogin()
base_dir = f"C:\\Users\\{username}\\Desktop\\monthly_report"
output_dir = os.path.join(base_dir, yyyymm)
os.makedirs(output_dir, exist_ok=True)

# --- DATE PARAMETERS ---
start_date = now.replace(day=1).strftime("%Y-%m-%d 00:00:00")
last_day = calendar.monthrange(now.year, now.month)[1]
end_date = now.replace(day=last_day).strftime("%Y-%m-%d 23:59:59")
print(f"Start date: {start_date}, End date: {end_date}")

# --- EXPORT TO XLSB ---
CHUNK_SIZE = 50000

def export_query_to_xlsx(query, filename, conn):
    xlsb_path = os.path.join(output_dir, filename)
    print(f"\n[+] Running query and exporting to: {filename}")
    wb = Workbook()
    ws = wb.active

    for chunk in pd.read_sql(query, conn, chunksize=CHUNK_SIZE):
        for row in chunk.itertuples(index=False):
            ws.append(row)
        print(f"    [✓] Appended chunk of {len(chunk)} rows")

    wb.save(xlsb_path)
    print(f"[✓] Finished: {filename}")

def export_query_to_xlsx_with_params(query, filename, conn, params):
    xlsb_path = os.path.join(output_dir, filename)
    print(f"\n[+] Running query and exporting to: {filename}")
    wb = Workbook()
    ws = wb.active

    for chunk in pd.read_sql(query, conn, params=params, chunksize=CHUNK_SIZE):
        for row in chunk.itertuples(index=False):
            ws.append(row)
        print(f"    [✓] Appended chunk of {len(chunk)} rows")

    wb.save(xlsb_path)
    print(f"[✓] Finished: {filename}")

# --- CONNECT TO DATABASE ---
hostname = "nrkdb03.bcgov"
port = "1521"
service_name = "dbp01.nrs.bcgov"

username = input("Enter your database username: ")
password = getpass.getpass("Enter your database password: ")

conn_str = (
    f"Driver={{Oracle in instantclient_19c}};"
    f"Dbq={hostname}:{port}/{service_name};"
    f"Uid={username};"
    f"Pwd={password};"
)

conn = pyodbc.connect(conn_str)
print("Connected successfully!")

# --- DEFINE QUERIES ---
sql_dir = os.path.join(base_dir, "queries")
queries = [
    (sql_filename, f"{os.path.splitext(sql_filename)[0]}_{yyyymm}.xlsx")
    for sql_filename in os.listdir(sql_dir)
    if sql_filename.endswith(".sql")
]

# --- RUN QUERIES ---
for sql_filename, xlsx_name in queries:
    query_path = os.path.join(sql_dir, sql_filename)
    with open(query_path, "r", encoding="utf-8") as f:
        query = f.read()

    print(f"\n[+] Running query and exporting to: {xlsx_name}")

    # Detect parameter markers (Oracle-style)
    param_markers = set(re.findall(r":(\w+)", query))
    param_count = query.count("?")
    print("    Params in SQL:  ", param_markers)
    print(f"  Found {param_count} parameter placeholders")

    if param_count >= 2:
        params = [start_date, end_date]
        print(f"  Using params (positional): {params}")
        export_query_to_xlsx_with_params(query, xlsx_name, conn, params)
    else:
        export_query_to_xlsx(query, xlsx_name, conn)

# --- CLEANUP ---
conn.close()
print("\n[✓] All XLSB exports completed.")