# nr-hbs-report-automated
Automate monthly HBS harvest report run by using Python

Use the following command to run report with report_config_2.yaml on TEST environment:
python monthly_report.py --config C:\Users\touyang\Desktop\monthly_report\report_config_2.yaml --env test

How to run timberwest_reports:
Open PowerShell as Administrator and run:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
Then run your script:
& "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\run_report.ps1"
This is the safest method because it does not change system-wide settings, only for the current session.
