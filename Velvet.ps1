# Velvet - PC Maintenance Utility
# Educational Project - Use with Caution
# Run as Administrator

#Requires -RunAsAdministrator

# Define colors
$successColor = "Green"
$errorColor = "Red"
$warningColor = "Yellow"
$infoColor = "Cyan"
$resetColor = "White"

# Validate admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor $errorColor
    pause
    exit
}

# Windows-style loading animation
function Show-LoadingAnimation {
    param([string]$message, [int]$duration = 3)
    
    $endTime = (Get-Date).AddSeconds($duration)
    $dotCount = 0
    $maxDots = 5
    
    while ((Get-Date) -lt $endTime) {
        $dots = "." * $dotCount
        $spaces = " " * ($maxDots - $dotCount)
        Write-Host "`r$message$dots$spaces" -NoNewline -ForegroundColor $infoColor
        Start-Sleep -Milliseconds 400
        $dotCount++
        if ($dotCount -gt $maxDots) { $dotCount = 0 }
    }
    Write-Host "`r$message - Complete!     " -ForegroundColor $successColor
}

# Progress bar animation
function Show-ProgressBar {
    param([string]$activity)
    
    Write-Host "`n$activity" -ForegroundColor $infoColor
    $progressChars = @("▱", "▰")
    
    for ($i = 0; $i -le 20; $i++) {
        $percent = ($i / 20) * 100
        $bar = ""
        
        for ($j = 0; $j -lt 20; $j++) {
            if ($j -lt $i) {
                $bar += $progressChars[1]
            } else {
                $bar += $progressChars[0]
            }
        }
        
        Write-Host "`r[$bar] $([math]::Round($percent))%" -NoNewline -ForegroundColor $infoColor
        Start-Sleep -Milliseconds 50
    }
    
    Write-Host "`r[████████████████████] 100% - Done!" -ForegroundColor $successColor
}

# Typewriter effect
function Show-TypeWriter {
    param([string]$text, [int]$speed = 30)
    
    foreach ($char in $text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $infoColor
        Start-Sleep -Milliseconds $speed
    }
    Write-Host ""
}

# Success celebration
function Show-Celebration {
    Clear-Host
    Write-Host "`n`n`n"
    Write-Host "        ╔═══════════════════════════════════╗" -ForegroundColor $successColor
    Write-Host "        ║                                   ║" -ForegroundColor $successColor
    Write-Host "        ║         ALL DONE!                ║" -ForegroundColor $successColor
    Write-Host "        ║                                   ║" -ForegroundColor $successColor
    Write-Host "        ║   Your PC has been optimized      ║" -ForegroundColor $successColor
    Write-Host "        ║                                   ║" -ForegroundColor $successColor
    Write-Host "        ╚═══════════════════════════════════╝" -ForegroundColor $successColor
    Write-Host "`n"
}

# Function to create system restore point
function Create-RestorePoint {
    try {
        # Check if System Restore is enabled
        $restoreEnabled = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        Checkpoint-Computer -Description "Velvet_Backup_$timestamp" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        return $true
    } catch {
        Write-Host "`n  Warning: Could not create restore point: $($_.Exception.Message)" -ForegroundColor $warningColor
        return $false
    }
}

# Preset Configurations
function Get-PresetConfig {
    param([string]$preset)
    
    $configs = @{
        "conservative" = @{
            Name = "Conservative Cleanup"
            RemoveApps = $true
            RemoveOffice = $false
            RemoveXbox = $false
            RemoveOneDrive = $false
            DisableTelemetry = $true
            DisableServices = $false
            DisableCortana = $false
            OptimizeSystem = $true
            CleanSystem = $true
        }
        "moderate" = @{
            Name = "Moderate Cleanup"
            RemoveApps = $true
            RemoveOffice = $false
            RemoveXbox = $true
            RemoveOneDrive = $false
            DisableTelemetry = $true
            DisableServices = $true
            DisableCortana = $true
            OptimizeSystem = $true
            CleanSystem = $true
        }
        "aggressive" = @{
            Name = "Aggressive Cleanup"
            RemoveApps = $true
            RemoveOffice = $true
            RemoveXbox = $true
            RemoveOneDrive = $true
            DisableTelemetry = $true
            DisableServices = $true
            DisableCortana = $true
            OptimizeSystem = $true
            CleanSystem = $true
        }
    }
    
    return $configs[$preset]
}

# Remove bloatware apps
function Remove-Apps {
    param(
        [bool]$RemoveOffice = $false,
        [bool]$RemoveXbox = $false
    )
    
    # Only remove commonly unwanted apps
    $bloatware = @(
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo"
    )
    
    if ($RemoveOffice) {
        $bloatware += @("Microsoft.Office.OneNote", "Microsoft.MicrosoftOfficeHub")
    }
    
    if ($RemoveXbox) {
        $bloatware += @("Microsoft.XboxApp", "Microsoft.XboxGamingOverlay", "Microsoft.GamingApp")
    }
    
    foreach ($app in $bloatware) {
        try {
            Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
                Where-Object DisplayName -like $app | 
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        } catch {
            # Silently continue on error
        }
    }
}

# Remove Xbox services
function Remove-Xbox {
    $xboxServices = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc")
    
    foreach ($service in $xboxServices) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            }
        } catch {
            # Silently continue
        }
    }
}

# Remove OneDrive
function Remove-OneDrive {
    try {
        # Stop OneDrive process
        Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        # Find OneDrive setup
        $onedrive = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
        if (!(Test-Path $onedrive)) {
            $onedrive = "$env:SystemRoot\System32\OneDriveSetup.exe"
        }
        
        # Uninstall OneDrive
        if (Test-Path $onedrive) {
            Start-Process $onedrive "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
        }
        
        # Clean up OneDrive folders
        Start-Sleep -Seconds 2
        Remove-Item -Path "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Disable OneDrive via registry
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -ErrorAction SilentlyContinue
    } catch {
        Write-Host "`n  Note: Some OneDrive components may still be present" -ForegroundColor $warningColor
    }
}

# Disable telemetry
function Disable-Telemetry {
    try {
        # Disable telemetry
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
        
        # Disable advertising ID
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1 -ErrorAction SilentlyContinue
        
        # Disable telemetry scheduled tasks
        Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -ErrorAction SilentlyContinue | 
            Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
        Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -ErrorAction SilentlyContinue | 
            Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
    } catch {
        # Silently continue
    }
}

# Disable background services
function Disable-BackgroundServices {
    $services = @("DiagTrack", "dmwappushservice")
    
    foreach ($service in $services) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.Status -eq 'Running') {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            }
        } catch {
            # Silently continue
        }
    }
}

# Optimize system
function Optimize-System {
    try {
        # Disable consumer features
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -ErrorAction SilentlyContinue
        
        # Disable silent app install
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -ErrorAction SilentlyContinue
    } catch {
        # Silently continue
    }
}

# Clean system
function Clean-System {
    try {
        # Clean temp folders
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # Clean Windows Update cache
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    } catch {
        # Silently continue
    }
}

# Disable Cortana
function Disable-CortanaWebSearch {
    try {
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -ErrorAction SilentlyContinue
    } catch {
        # Silently continue
    }
}

# Apply preset with animations
function Apply-Preset {
    param([string]$presetName)
    
    $config = Get-PresetConfig $presetName
    
    Clear-Host
    Write-Host "`n`n"
    Show-TypeWriter "  Starting optimization: $($config.Name)" 40
    Write-Host "`n"
    Start-Sleep -Milliseconds 800
    
    # Step 1: Safety backup
    Show-LoadingAnimation "Creating system restore point" 2
    $restoreCreated = Create-RestorePoint
    if (-not $restoreCreated) {
        Write-Host "`n  Warning: Restore point creation failed. Continue? (Y/N): " -ForegroundColor $warningColor -NoNewline
        $continue = Read-Host
        if ($continue -ne 'Y' -and $continue -ne 'y') {
            Write-Host "`n  Operation cancelled." -ForegroundColor $errorColor
            pause
            exit
        }
    }
    Start-Sleep -Milliseconds 500
    
    # Step 2: Remove apps
    if ($config.RemoveApps) {
        Show-LoadingAnimation "Removing unnecessary apps" 3
        Remove-Apps -RemoveOffice $config.RemoveOffice -RemoveXbox $config.RemoveXbox
        Start-Sleep -Milliseconds 500
    }
    
    # Step 3: Remove Xbox
    if ($config.RemoveXbox) {
        Show-LoadingAnimation "Removing Xbox services" 2
        Remove-Xbox
        Start-Sleep -Milliseconds 500
    }
    
    # Step 4: Remove OneDrive
    if ($config.RemoveOneDrive) {
        Show-LoadingAnimation "Removing OneDrive" 2
        Remove-OneDrive
        Start-Sleep -Milliseconds 500
    }
    
    # Step 5: Disable telemetry
    if ($config.DisableTelemetry) {
        Show-LoadingAnimation "Disabling telemetry" 2
        Disable-Telemetry
        Start-Sleep -Milliseconds 500
    }
    
    # Step 6: Services
    if ($config.DisableServices) {
        Show-LoadingAnimation "Disabling background services" 2
        Disable-BackgroundServices
        Start-Sleep -Milliseconds 500
    }
    
    # Step 7: Cortana
    if ($config.DisableCortana) {
        Show-LoadingAnimation "Disabling Cortana" 2
        Disable-CortanaWebSearch
        Start-Sleep -Milliseconds 500
    }
    
    # Step 8: Optimize
    if ($config.OptimizeSystem) {
        Show-LoadingAnimation "Optimizing system settings" 2
        Optimize-System
        Start-Sleep -Milliseconds 500
    }
    
    # Step 9: Clean
    if ($config.CleanSystem) {
        Show-LoadingAnimation "Cleaning temporary files" 3
        Clean-System
        Start-Sleep -Milliseconds 500
    }
    
    # Final progress
    Write-Host "`n"
    Show-ProgressBar "Finalizing optimization"
    Start-Sleep -Milliseconds 800
    
    # Celebration
    Show-Celebration
    
    Write-Host "        Please restart your computer" -ForegroundColor $warningColor
    Write-Host "        to complete the optimization.`n" -ForegroundColor $warningColor
    Write-Host "        Press Enter to exit..." -ForegroundColor $resetColor
    Read-Host
}

# Welcome screen
Clear-Host
Write-Host "`n`n`n"

$title = @(
    "        ╔════════════════════════════════════╗",
    "        ║                                    ║",
    "        ║          VELVET OPTIMIZER          ║",
    "        ║     PC Maintenance & Cleanup       ║",
    "        ║                                    ║",
    "        ╚════════════════════════════════════╝"
)

foreach ($line in $title) {
    Write-Host $line -ForegroundColor $infoColor
    Start-Sleep -Milliseconds 100
}

Write-Host "`n"
Start-Sleep -Milliseconds 500

Write-Host "        Initializing" -NoNewline -ForegroundColor $infoColor
for ($i = 0; $i -lt 5; $i++) {
    Write-Host "." -NoNewline -ForegroundColor $infoColor
    Start-Sleep -Milliseconds 200
}
Write-Host " Ready!`n" -ForegroundColor $successColor
Start-Sleep -Milliseconds 800

# Warning message
Clear-Host
Write-Host "`n════════════════════════════════════════" -ForegroundColor $warningColor
Write-Host "  IMPORTANT NOTICE" -ForegroundColor $warningColor
Write-Host "════════════════════════════════════════`n" -ForegroundColor $warningColor
Write-Host "  This script will modify your system." -ForegroundColor $resetColor
Write-Host "  A restore point will be created." -ForegroundColor $resetColor
Write-Host "  Use at your own risk.`n" -ForegroundColor $resetColor
Write-Host "  Continue? (Y/N): " -ForegroundColor $warningColor -NoNewline
$confirm = Read-Host

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "`n  Operation cancelled." -ForegroundColor $errorColor
    pause
    exit
}

# Menu
Clear-Host
Write-Host "`n════════════════════════════════════════" -ForegroundColor $infoColor
Write-Host "  Choose Optimization Level:" -ForegroundColor $infoColor
Write-Host "════════════════════════════════════════`n" -ForegroundColor $infoColor

Write-Host "  1. Conservative Cleanup" -ForegroundColor $resetColor
Write-Host "     (Minimal changes, safe for most users)`n" -ForegroundColor DarkGray

Write-Host "  2. Moderate Cleanup" -ForegroundColor $resetColor
Write-Host "     (Balanced optimization)`n" -ForegroundColor DarkGray

Write-Host "  3. Aggressive Cleanup" -ForegroundColor $resetColor
Write-Host "     (Maximum cleanup, removes more apps)`n" -ForegroundColor DarkGray

Write-Host "════════════════════════════════════════`n" -ForegroundColor $infoColor

Write-Host "Enter a number (1-3): " -ForegroundColor $warningColor -NoNewline
$choice = Read-Host

switch ($choice) {
    1 { Apply-Preset "conservative" }
    2 { Apply-Preset "moderate" }
    3 { Apply-Preset "aggressive" }
    default {
        Write-Host "`nInvalid choice. Please run the script again." -ForegroundColor $errorColor
        Start-Sleep -Seconds 3
    }
}
