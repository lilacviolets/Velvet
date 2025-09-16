# Velvet - PowerShell Debloating Utility

# Define colors for user feedback
$successColor = [Console]::ForegroundColor = "Green"
$errorColor = [Console]::ForegroundColor = "Red"
$warningColor = [Console]::ForegroundColor = "Yellow"
$infoColor = [Console]::ForegroundColor = "Cyan"
$resetColor = [Console]::ForegroundColor = "White"

# Welcome Message
Write-Host "Welcome to Velvet - Your PC Debloating Utility" -ForegroundColor $infoColor
Write-Host "---------------------------------------------" -ForegroundColor $infoColor
Write-Host "This script will help optimize and debloat your system." -ForegroundColor $resetColor
Write-Host "Please ensure you run this script as Administrator." -ForegroundColor $warningColor
Write-Host "Select an option to continue..." -ForegroundColor $resetColor

# Display Menu
function Display-Menu {
    Write-Host "1. Remove Unnecessary Apps" -ForegroundColor $warningColor
    Write-Host "2. Disable Telemetry & Background Services" -ForegroundColor $warningColor
    Write-Host "3. Optimize System Settings" -ForegroundColor $warningColor
    Write-Host "4. Clean up System (Temporary Files, Cache)" -ForegroundColor $warningColor
    Write-Host "5. Exit" -ForegroundColor $warningColor
}

# Action to remove unnecessary apps
function Remove-Apps {
    Write-Host "Removing unnecessary apps..." -ForegroundColor $warningColor
    try {
        # Remove common pre-installed apps (excluding Windows Store)
        Get-AppxPackage | where {$_.Name -notlike "*Microsoft.WindowsStore*"} | Remove-AppxPackage
        Write-Host "Unnecessary apps removed successfully." -ForegroundColor $successColor
    } catch {
        Write-Host "Error: Failed to remove apps. Ensure you are running the script as Administrator." -ForegroundColor $errorColor
    }
}

# Action to disable telemetry and unnecessary services
function Disable-Telemetry {
    Write-Host "Disabling telemetry and background services..." -ForegroundColor $warningColor
    try {
        # Disable Windows Telemetry
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
        # Disable background services (Example: DiagTrack, which is the Microsoft Compatibility Telemetry service)
        Stop-Service -Name "DiagTrack" -Force
        Set-Service -Name "DiagTrack" -StartupType Disabled
        Write-Host "Telemetry and background services disabled." -ForegroundColor $successColor
    } catch {
        Write-Host "Error: Failed to disable telemetry." -ForegroundColor $errorColor
    }
}

# Action to optimize system settings
function Optimize-System {
    Write-Host "Optimizing system settings..." -ForegroundColor $warningColor
    try {
        # Disable OneDrive (Example of disabling startup items)
        Stop-Process -Name "OneDrive" -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "UserLoggedIn" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "HomeUserUpn" -Value ""
        
        # Example of disabling Windows Defender real-time protection (be cautious with this)
        Set-MpPreference -DisableRealtimeMonitoring $true
        Write-Host "System optimized successfully." -ForegroundColor $successColor
    } catch {
        Write-Host "Error: Failed to optimize system settings." -ForegroundColor $errorColor
    }
}

# Clean up temporary files, cache, and Windows update leftovers
function Clean-System {
    Write-Host "Cleaning system temporary files and cache..." -ForegroundColor $warningColor
    try {
        # Clear system temp files
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force

        # Clean up Windows Update leftovers
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
        Write-Host "System cleaned successfully." -ForegroundColor $successColor
    } catch {
        Write-Host "Error: Failed to clean system." -ForegroundColor $errorColor
    }
}

# Main logic to select options
do {
    Display-Menu
    $userChoice = Read-Host "Enter the number of your choice"

    switch ($userChoice) {
        1 {
            Remove-Apps
        }
        2 {
            Disable-Telemetry
        }
        3 {
            Optimize-System
        }
        4 {
            Clean-System
        }
        5 {
            Write-Host "Exiting Velvet. Goodbye!" -ForegroundColor $infoColor
            break
        }
        default {
            Write-Host "Invalid choice, please try again." -ForegroundColor $errorColor
        }
    }

    Write-Host "Would you like to perform another action? (Y/N)" -ForegroundColor $infoColor
    $continue = Read-Host
} while ($continue -eq "Y" -or $continue -eq "y")

Write-Host "Thank you for using Velvet!" -ForegroundColor $infoColor
