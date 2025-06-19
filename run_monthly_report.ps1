# --- CONFIG ---
$today = Get-Date -Format "yyyyMMdd"
$username = $env:USERNAME

$basePath =  "C:\Users\$username\fds_proj\HBS_Monthly_Report_Automation"
$logPath = "C:\Users\$username\Desktop\monthly_report\logs\run_log_$today.txt"
$script64 = "$basePath\monthly_report.py"
$script32 = "$basePath\convertformat.py"
$py64 = "$basePath\venv64\Scripts\python.exe"
$py32 = "$basePath\venv32\Scripts\python.exe"

# Ensure log directory exists
New-Item -Path (Split-Path $logPath) -ItemType Directory -Force | Out-Null

# --- LOGGING ---
Start-Transcript -Path $logPath -Append

# --- CHECK IF WEEKDAY ---
$dayOfWeek = (Get-Date).DayOfWeek
if ($dayOfWeek -eq 'Saturday' -or $dayOfWeek -eq 'Sunday') {
    Write-Output "Weekend detected. Skipping run."
    Stop-Transcript
    exit
}

try {
    Write-Output "===== Starting Data Job at $(Get-Date) ====="

    # Run 64-bit Python script
    Write-Output "Running 64-bit script..."
    & $py64 $script64

    # Run 32-bit Python script
    Write-Output "Running 32-bit script..."
    & $py32 $script32

    Write-Output "===== Finished Successfully at $(Get-Date) ====="
}
catch {
    $errorMsg = "Report job failed at $(Get-Date): $($_.Exception.Message)"
    Write-Output $errorMsg

 
}
finally {
    Stop-Transcript
}
