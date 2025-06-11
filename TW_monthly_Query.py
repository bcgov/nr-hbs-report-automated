import pandas as pd
import sys
import os
from datetime import datetime
import calendar
from my_db_module import get_connection
import re

# --- CONFIGURATION ---
env = sys.argv[1] if len(sys.argv) > 1 else "test"
env = env.lower()
yyyymm = datetime.now().strftime("%Y%m")
now = datetime.now()

output_dir = r"C:\Users\touyang\Desktop\timberwest_report"
os.makedirs(output_dir, exist_ok=True)

# --- DATE PARAMETERS ---
start_date = now.replace(day=1).strftime("%Y-%m-%d 00:00:00")
last_day = calendar.monthrange(now.year, now.month)[1]
end_date = now.replace(day=last_day).strftime("%Y-%m-%d 23:59:59")
print(f"Start date: {start_date}, End date: {end_date}")  # Print the values

# Chunk size for large query processing
CHUNK_SIZE = 50000

# --- EXPORT CSV LOGIC ---
def export_query_to_csv(query, filename, conn):
    csv_path = os.path.join(output_dir, filename)
    print(f"\n[+] Running query and exporting to: {filename}")
    first_chunk = True

    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        for chunk in pd.read_sql(query, conn, chunksize=CHUNK_SIZE):
            chunk.to_csv(f, index=False, header=first_chunk, mode="a", encoding="utf-8")
            print(f"    [✓] Appended chunk of {len(chunk)} rows")
            first_chunk = False

    print(f"[✓] Finished: {filename}")

# define parameterized export
def export_query_to_csv_with_params(query, filename, conn, params):
    csv_path = os.path.join(output_dir, filename)
    print(f"\n[+] Running query and exporting to: {filename}")
    first_chunk = True

    with open(csv_path, "w", encoding="utf-8", newline="") as f:
        for chunk in pd.read_sql(query, conn, params=params, chunksize=CHUNK_SIZE):
            chunk.to_csv(f, index=False, header=first_chunk, mode="a", encoding="utf-8")
            print(f"    [✓] Appended chunk of {len(chunk)} rows")
            first_chunk = False

    print(f"[✓] Finished: {filename}")

# --- CONNECT TO DATABASE ---
print(f"\n[+] Connecting to environment: {env}")
conn = get_connection(env=env)

# --- DEFINE QUERIES ---
sql_dir = os.path.join(os.path.dirname(__file__), "queries")

queries = [
    ("client.sql", f"client_{yyyymm}.csv"),
    ("scalesite.sql", f"scalesite_{yyyymm}.csv"),
    ("Licence.sql", f"licence_{yyyymm}.csv"),
    ("markdistrict.sql", f"markdistrict_{yyyymm}.csv"),
    ("monthlydata.sql", f"monthlydata_{yyyymm}.csv"),
    ("latest_tsb.sql", f"tsb_{yyyymm}.csv"),
]

# --- RUN QUERIES ---
for sql_filename, csv_name in queries:
    query_path = os.path.join(sql_dir, sql_filename)
    with open(query_path, "r", encoding="utf-8") as f:
        query = f.read()

    print(f"[+] Running query and exporting to: {csv_name}")

    # ——— DEBUG: show what bind‐variables are in the SQL vs what you pass
    param_markers = set(re.findall(r":(\w+)", query))
    print("    Params in SQL:  ", param_markers)
    # (you’ll define params below, so this shows SQL’s needs)

    if sql_filename == "monthlydata.sql":
        params = [
            start_date,
            end_date,
            start_date,
            end_date
        ]
        print(f"  Using params (positional): {params}")
        export_query_to_csv_with_params(query, csv_name, conn, params)
    else:
        export_query_to_csv(query, csv_name, conn)

# --- CLEANUP C
# ONNECTION ---
conn.close()
print("\n[✓] All CSV exports completed.")
