# --- CONFIG ---
$today = Get-Date -Format "yyyyMMdd"
$logPath = "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\logs\run_log_$today.txt"
$script64 = "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\TW_monthly_Query.py"
$script32 = "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\transferFormat.py"
$py64 = "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\venv64\Scripts\python.exe"
$py32 = "C:\Users\touyang\fds_proj\HBS_Monthly_Report_Automation\venv32\Scripts\python.exe"

# Email (if error occurs)
#$emailTo = "ting.ouyang@gov.bc.ca"
#$emailFrom = "taskrunner@yourdomain.com"
#$smtpServer = "smtp.yourdomain.com"
#$smtpPort = 587
#$smtpUser = "taskrunner@yourdomain.com"
#$smtpPass = "your_app_password"

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
    & $py64 $script64 "prod"

    # Run 32-bit Python script
    Write-Output "Running 32-bit script..."
    & $py32 $script32 "prod"

    Write-Output "===== Finished Successfully at $(Get-Date) ====="
}
catch {
    $errorMsg = "Report job failed at $(Get-Date): $($_.Exception.Message)"
    Write-Output $errorMsg

    # Email on failure
<#     $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPass)
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $emailFrom
    $mailMessage.To.Add($emailTo)
    $mailMessage.Subject = "Data Job Failed"
    $mailMessage.Body = $errorMsg #>

#   $smtp.Send($mailMessage)
}
finally {
    Stop-Transcript
}
