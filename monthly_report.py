import pandas as pd
import sys
import os
from datetime import datetime
import calendar
import re
from openpyxl import Workbook
import pyodbc
import getpass
import yaml

# --- CONFIGURATION ---
yyyymm = datetime.now().strftime("%Y%m")
now = datetime.now()

username = os.getlogin()
base_dir = f"C:\\Users\\{username}\\Desktop\\monthly_report"

config_path = os.path.join(base_dir, "report_config.yaml")

with open(config_path, "r") as f:
    config = yaml.safe_load(f)

queries_root = os.path.normpath(config["paths"]["queries_root"])
templates_root = os.path.normpath(config["paths"]["templates_root"])
reports_root = os.path.normpath(config["paths"]["reports_root"])

# --- CHUNK export function ---
CHUNK_SIZE = 50000

def export_query_to_xlsx(query, filename, conn, output_dir, params = None):
    xlsx_path = os.path.join(output_dir, filename)
    print(f"\n[+] Running query and exporting to: {filename}")
    wb = Workbook()
    ws = wb.active
    row_counter = 0

    for chunk in pd.read_sql(query, conn, params=params,chunksize=CHUNK_SIZE):
        for row in chunk.itertuples(index=False):
            ws.append(row)
        row_counter += len(chunk)
        print(f"    [✓] Appended chunk of {len(chunk)} rows")

    wb.save(xlsx_path)
    print(f"[✓] Finished: {filename} ({row_counter} rows)")

# --- Date range logic ---
def get_date_range(rspec, today):
    end_date = today
    if rspec["type"] == "trailing_months":
        months = rspec["months"]
        start_date = (end_date.replace(day=1) - pd.DateOffset(months=months)).date()
    elif rspec["type"] == "fixed":
        start_val = rspec["start"]
        if isinstance(start_val, str):
           start_date = datetime.strptime(start_val, "%Y-%m-%d").date()
        else:
           start_date = start_val
    else:
        raise ValueError("Invalid date_range type")
    return start_date, end_date

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

# === Process each reportTo user ===
for person in config["reportTo"]:
    name = person["name"]

    for report in person["reports"]:
        topic = report["topic"]
        date_range = report["date_range"]

        sql_path = os.path.normpath(os.path.join(queries_root, name, report["sql"]))
        template_path = os.path.normpath(os.path.join(templates_root, name, report["template"]))
        output_dir = os.path.normpath(os.path.join(reports_root, name, yyyymm))
        os.makedirs(output_dir, exist_ok=True)
        output_filename = f"{topic}_{yyyymm}_{name}.xlsx"
        output_path = os.path.normpath(os.path.join(output_dir, output_filename))

        print(f"SQL path: {sql_path}")
        print(f"Template path: {template_path}")
        print(f"Output path: {output_dir}")

        # Load and parameterize the SQL
        with open(sql_path, "r", encoding="utf-8") as f:
            query = f.read()

        start_date, end_date = get_date_range(date_range, now)
        print(f"Using date range: {start_date} to {end_date}")

        param_count = query.count("?")
        if param_count >= 2:
            export_query_to_xlsx(query, output_filename, conn, output_dir, params=[start_date, end_date])
        else:
            export_query_to_xlsx(query, output_filename, conn, output_dir)

# --- CLEANUP ---
conn.close()
print("\n[✓] All XLSB exports completed.")