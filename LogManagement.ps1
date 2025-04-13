# LogManagement.ps1
# LOG DELETION PROCEDURE

Write-Host "RUNNING: Local Log Deletion" -ForegroundColor Red
Write-Host "DELETING LOGGS!" -ForegroundColor Yellow

# List of common network-related logs to target
$targetLogs = @(
    "Security",         # Authentication events
    "System",           # Network driver events
    "Application",	# Generic app logs
    "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall"  # FW logs
)

# Add file-based logs (common for apps)
$targetFiles = @(
    "C:\*.log"
    #"M:\*.log,
    #"Q:\*.log # Add/remove drives as needed!!!
    #"$env:APPDATA\AnotherApp\debug.log" # template for any app you wish to add to the list!
)

function Clear-NetworkLogs {
    [CmdletBinding()]
    param()

    try {
        # Check for admin privileges
        if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "Not running as admin - most logs will persist!"
            return
        }

        # Loop through target logs
        foreach ($log in $targetLogs) {
            Write-Output "`nAttempting to clear: $log"
            
            # Try to clear log (may fail for some protected logs)
            wevtutil.exe clear-log $log 2>&1 | Out-Null
            
            # Verification check
            $remaining = (Get-WinEvent -LogName $log -MaxEvents 1 -ErrorAction SilentlyContinue).Count
            Write-Host "Log '$log' now contains $remaining events" -ForegroundColor Cyan
        }

        # advanced cleanup
        Write-Output "`nClearing DNS cache (ipconfig /flushdns)"
        ipconfig /flushdns | Out-Null

    }
    catch {
        Write-Host "Error during demo: $_" -ForegroundColor Red
    }
}

# Execute with visible warnings
Clear-NetworkLogs

# Final educational note
Write-Host "`n`nDONE" -ForegroundColor Green
Write-Host "This script deleted LOCAL logs, but proper security requires:"
Write-Host "1. Remote syslog servers (e.g., Splunk, ELK)"
Write-Host "2. Immutable cloud storage (AWS CloudTrail, Azure Sentinel)"
Write-Host "3. Network-based packet capture (Corelight, Zeek)"