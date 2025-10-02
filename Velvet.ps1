# Velvet - Simple PC Cleanup Tool
# Educational School Project - For Learning Purposes Only
# Created by: [Your Name/Class]
# 
# DISCLAIMER: This is a student project for educational purposes.
# Always backup your data before running system modification scripts.
# Run as Administrator

#Requires -RunAsAdministrator

Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "     VELVET PC CLEANUP" -ForegroundColor Cyan
Write-Host "     School Project 2024" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

Write-Host "This script will:" -ForegroundColor White
Write-Host "  • Remove some pre-installed Windows apps" -ForegroundColor Gray
Write-Host "  • Reduce telemetry data collection" -ForegroundColor Gray
Write-Host "  • Clean temporary files" -ForegroundColor Gray
Write-Host "  • Disable Cortana web search`n" -ForegroundColor Gray

Write-Host "IMPORTANT:" -ForegroundColor Yellow
Write-Host "  • A restore point will be created" -ForegroundColor Yellow
Write-Host "  • This modifies system settings" -ForegroundColor Yellow
Write-Host "  • Requires restart after completion`n" -ForegroundColor Yellow

$confirm = Read-Host "Do you want to continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "`nOperation cancelled." -ForegroundColor Red
    pause
    exit
}

Write-Host "`n--- Starting Cleanup Process ---`n" -ForegroundColor Cyan

# Step 1: Create restore point
Write-Host "[1/6] Creating system restore point..." -ForegroundColor Cyan
try {
    Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Velvet_Backup_$(Get-Date -Format 'yyyy-MM-dd_HH-mm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "      ✓ Restore point created successfully" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Warning: Could not create restore point" -ForegroundColor Yellow
    Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Yellow
    $continue = Read-Host "`n      Continue without restore point? (Y/N)"
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        Write-Host "`nOperation cancelled." -ForegroundColor Red
        pause
        exit
    }
}

# Step 2: Remove bloatware apps
Write-Host "`n[2/6] Removing unnecessary apps..." -ForegroundColor Cyan
$bloatware = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

$removedCount = 0
foreach ($app in $bloatware) {
    $package = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
    if ($package) {
        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
        $removedCount++
    }
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
        Where-Object DisplayName -like $app | 
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "      ✓ Removed $removedCount apps" -ForegroundColor Green

# Step 3: Reduce telemetry
Write-Host "`n[3/6] Reducing telemetry and diagnostics..." -ForegroundColor Cyan
try {
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction Stop
    
    # Disable telemetry scheduled tasks
    Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -ErrorAction SilentlyContinue | 
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
    
    Write-Host "      ✓ Telemetry settings adjusted" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Warning: Some telemetry settings could not be changed" -ForegroundColor Yellow
}

# Step 4: Disable unnecessary services
Write-Host "`n[4/6] Disabling unnecessary services..." -ForegroundColor Cyan
$services = @("DiagTrack", "dmwappushservice")
$disabledCount = 0

foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        try {
            Stop-Service -Name $service -Force -ErrorAction Stop
            Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
            $disabledCount++
        } catch {
            Write-Host "      ✗ Could not disable service: $service" -ForegroundColor Yellow
        }
    }
}
Write-Host "      ✓ Disabled $disabledCount services" -ForegroundColor Green

# Step 5: Clean temporary files
Write-Host "`n[5/6] Cleaning temporary files..." -ForegroundColor Cyan
$cleanedSize = 0

try {
    $tempSize = (Get-ChildItem -Path "$env:TEMP" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    $cleanedSize += $tempSize
} catch {}

try {
    $systemTempSize = (Get-ChildItem -Path "$env:SystemRoot\Temp" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    $cleanedSize += $systemTempSize
} catch {}

# Clean Windows Update cache
try {
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
} catch {}

$cleanedMB = [math]::Round($cleanedSize / 1MB, 2)
Write-Host "      ✓ Cleaned approximately $cleanedMB MB" -ForegroundColor Green

# Step 6: Disable Cortana web search
Write-Host "`n[6/6] Disabling Cortana web search..." -ForegroundColor Cyan
try {
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction Stop
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -ErrorAction Stop
    Write-Host "      ✓ Cortana web search disabled" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Warning: Could not disable Cortana" -ForegroundColor Yellow
}

# Summary
Write-Host "`n================================" -ForegroundColor Green
Write-Host "     CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

Write-Host "`nSummary:" -ForegroundColor White
Write-Host "  • Removed $removedCount bloatware apps" -ForegroundColor Gray
Write-Host "  • Disabled $disabledCount unnecessary services" -ForegroundColor Gray
Write-Host "  • Cleaned $cleanedMB MB of temporary files" -ForegroundColor Gray
Write-Host "  • Reduced telemetry collection" -ForegroundColor Gray
Write-Host "  • Disabled Cortana web search" -ForegroundColor Gray

Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Please restart your computer" -ForegroundColor Yellow
Write-Host "  2. Check that everything works normally" -ForegroundColor Yellow
Write-Host "  3. If you have issues, restore from the backup point" -ForegroundColor Yellow

Write-Host "`nTo restore: Control Panel > System > System Protection > System Restore`n" -ForegroundColor Cyan

pause
