import os
import csv
import pyodbc
import shutil
import zipfile
from datetime import datetime, timedelta
import time

# --- CONFIG ---
template_mdb = "C:/Users/touyang/Desktop/timberwest_report/monthlyreport.mdb"
output_dir = "C:/Users/touyang/Desktop/timberwest_report"
csv_folder = "C:/Users/touyang/Desktop/timberwest_report"

# --- SET DATE ---
now = datetime.now()
first_day_this_month = now.replace(day=1)
last_month_date = first_day_this_month - timedelta(days=1)
yyyymm = last_month_date.strftime("%Y%m")
new_mdb = os.path.join(output_dir, f"monthlyreport_{yyyymm}.mdb")

# --- COPY TEMPLATE ---
shutil.copy(template_mdb, new_mdb)
print(f"[+] Created new Access DB from template: {new_mdb}")

# --- CONNECT TO COPIED MDB ---
conn_str = (
    r"Driver={Microsoft Access Driver (*.mdb)};"
    rf"DBQ={new_mdb};"
)
conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# --- IMPORT CSVs --- 
for filename in os.listdir(csv_folder):
    if not filename.lower().endswith(".csv"):
        continue

    table_name = filename.split("_")[0]
    csv_path = os.path.join(csv_folder, filename)

    print(f"[+] Importing {filename} into table: {table_name}")

    with open(csv_path, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader)  # Skip CSV header

        # Get column names from Access table (actual order preserved)
        cursor.execute(f"SELECT * FROM {table_name} WHERE 1=0")
        table_columns = [col[0] for col in cursor.description]

        print(f"Table: {table_name}")
        print(f"Access Columns ({len(table_columns)}): {table_columns}")


        # Wrap column names in brackets
        columns_wrapped = [f"[{col}]" for col in table_columns]
        placeholders = ", ".join(["?"] * len(table_columns))
        insert_sql = f"INSERT INTO {table_name} ({', '.join(columns_wrapped)}) VALUES ({placeholders})"

        for row in reader:
            row = [val if val != "" else None for val in row]
          # row = row[:len(table_columns)]  # Trim if too long
            
            print(f"CSV Row ({len(row)}): {row}")

            try:
                cursor.execute(insert_sql, row)
            except Exception as e:
                print(f"[!] Failed to insert row: {row}")
                print(f"    Error: {e}")

# Path to your .mdb file (after processing is done)
mdb_file_path = f"C:/Users/touyang/Desktop/timberwest_report/monthlyreport_{yyyymm}.mdb"
zip_file_path = mdb_file_path.replace(".mdb", ".zip")
print(f"[+] Finished importing CSVs into {mdb_file_path}")

# --- FINALIZE ---
conn.commit()
cursor.close()
conn.close()

# Create a zip file containing the .mdb file
with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
    zipf.write(mdb_file_path, arcname=os.path.basename(mdb_file_path))
print(f"[+] Zipped MDB file created: {zip_file_path}")

# Clean up the original .csv files
for filename in os.listdir(csv_folder):
    if filename.lower().endswith(".csv"):
        try:
            os.remove(os.path.join(csv_folder, filename))
            print(f"[-] Deleted CSV: {filename}")
        except Exception as e:
            print(f"[!] Failed to delete {filename}: {e}")