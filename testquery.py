import os
import chardet

sql_dir = r"C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\queries"

for filename in os.listdir(sql_dir):
    if filename.lower().endswith(".sql"):
        filepath = os.path.join(sql_dir, filename)
        with open(filepath, 'rb') as f:
            raw_data = f.read()
            result = chardet.detect(raw_data)
            print(f"{filename}: {result['encoding']} (confidence {result['confidence']:.2f})")