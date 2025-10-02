# Velvet - Simple PC Debloating Utility
# School Project - Easy to Use!
# Run as Administrator!

#Requires -RunAsAdministrator

# Define colors
$successColor = "Green"
$errorColor = "Red"
$warningColor = "Yellow"
$infoColor = "Cyan"
$resetColor = "White"

# Windows-style loading animation with moving dots
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
    
    Write-Host "`r[████████████████████] 100% ✓" -ForegroundColor $successColor
}

# Sparkle effect
function Show-Sparkles {
    param([string]$text)
    
    $sparkles = @("✨", "⭐", "🌟", "💫", "✨")
    
    for ($i = 0; $i -lt 5; $i++) {
        Clear-Host
        Write-Host "`n`n`n" -NoNewline
        Write-Host "        $($sparkles[$i]) " -NoNewline -ForegroundColor Yellow
        Write-Host $text -NoNewline -ForegroundColor $infoColor
        Write-Host " $($sparkles[4-$i])" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 300
    }
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
    Write-Host "        ║         🎉 ALL DONE! 🎉          ║" -ForegroundColor $successColor
    Write-Host "        ║                                   ║" -ForegroundColor $successColor
    Write-Host "        ║   Your PC is now optimized and   ║" -ForegroundColor $successColor
    Write-Host "        ║        running faster!            ║" -ForegroundColor $successColor
    Write-Host "        ║                                   ║" -ForegroundColor $successColor
    Write-Host "        ╚═══════════════════════════════════╝" -ForegroundColor $successColor
    Write-Host "`n"
    
    # Bouncing effect
    for ($i = 0; $i -lt 3; $i++) {
        Start-Sleep -Milliseconds 200
        Write-Host "                    ⬆️ ⬆️ ⬆️" -ForegroundColor Yellow
        Start-Sleep -Milliseconds 200
        Write-Host "`r                    ⬇️ ⬇️ ⬇️" -ForegroundColor Yellow -NoNewline
    }
    Write-Host "`n"
}

# Function to create system restore point (silent in background)
function Create-RestorePoint {
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        Checkpoint-Computer -Description "Velvet_Backup_$timestamp" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

# Preset Configurations
function Get-PresetConfig {
    param([string]$preset)
    
    $configs = @{
        "teacher" = @{
            Name = "Teacher / Office Work"
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
        "student" = @{
            Name = "Student"
            RemoveApps = $true
            RemoveOffice = $false
            RemoveXbox = $true
            RemoveOneDrive = $false
            DisableTelemetry = $true
            DisableServices = $false
            DisableCortana = $false
            OptimizeSystem = $true
            CleanSystem = $true
        }
        "gamer" = @{
            Name = "Gaming"
            RemoveApps = $true
            RemoveOffice = $true
            RemoveXbox = $false
            RemoveOneDrive = $true
            DisableTelemetry = $true
            DisableServices = $false
            DisableCortana = $true
            OptimizeSystem = $true
            CleanSystem = $true
        }
        "home" = @{
            Name = "Home / Family PC"
            RemoveApps = $true
            RemoveOffice = $false
            RemoveXbox = $true
            RemoveOneDrive = $false
            DisableTelemetry = $true
            DisableServices = $false
            DisableCortana = $false
            OptimizeSystem = $true
            CleanSystem = $true
        }
        "maximum" = @{
            Name = "Maximum Cleanup"
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

# Remove bloatware apps (silent)
function Remove-Apps {
    param(
        [bool]$RemoveOffice = $true,
        [bool]$RemoveXbox = $true
    )
    
    $bloatware = @(
        "Microsoft.BingNews", "Microsoft.BingWeather", "Microsoft.GetHelp",
        "Microsoft.Getstarted", "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.People", "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera",
        "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps", 
        "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo"
    )
    
    if ($RemoveOffice) {
        $bloatware += @("Microsoft.Office.OneNote", "Microsoft.MicrosoftOfficeHub")
    }
    
    if ($RemoveXbox) {
        $bloatware += @("Microsoft.XboxApp", "Microsoft.XboxGamingOverlay", "Microsoft.GamingApp")
    }
    
    foreach ($app in $bloatware) {
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }
}

# Remove Xbox services (silent)
function Remove-Xbox {
    $xboxServices = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc")
    
    foreach ($service in $xboxServices) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# Remove OneDrive (silent)
function Remove-OneDrive {
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    
    $onedrive = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (!(Test-Path $onedrive)) {
        $onedrive = "$env:SystemRoot\System32\OneDriveSetup.exe"
    }
    
    if (Test-Path $onedrive) {
        Start-Process $onedrive "/uninstall" -NoNewWindow -Wait -ErrorAction SilentlyContinue
    }
    
    Remove-Item -Path "$env:USERPROFILE\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -ErrorAction SilentlyContinue
}

# Disable telemetry (silent)
function Disable-Telemetry {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -ErrorAction SilentlyContinue
    
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1 -ErrorAction SilentlyContinue
    
    Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

# Disable background services (silent)
function Disable-BackgroundServices {
    $services = @("DiagTrack", "dmwappushservice", "WerSvc")
    
    foreach ($service in $services) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

# Optimize system (silent)
function Optimize-System {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -ErrorAction SilentlyContinue
}

# Clean system (silent)
function Clean-System {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:SystemRoot\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
}

# Disable Cortana (silent)
function Disable-CortanaWebSearch {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -ErrorAction SilentlyContinue
}

# Apply preset with animations
function Apply-Preset {
    param([string]$presetName)
    
    $config = Get-PresetConfig $presetName
    
    Clear-Host
    Show-Sparkles "Preparing Your PC Optimization"
    Start-Sleep -Milliseconds 500
    
    Clear-Host
    Write-Host "`n`n"
    Show-TypeWriter "  Starting magic optimization for: $($config.Name)" 40
    Write-Host "`n"
    Start-Sleep -Milliseconds 800
    
    # Step 1: Safety backup
    Show-LoadingAnimation "Creating safety backup" 2
    Create-RestorePoint | Out-Null
    Start-Sleep -Milliseconds 500
    
    # Step 2: Remove apps
    if ($config.RemoveApps) {
        Show-LoadingAnimation "Removing unnecessary apps" 3
        Remove-Apps -RemoveOffice $config.RemoveOffice -RemoveXbox $config.RemoveXbox
        Start-Sleep -Milliseconds 500
    }
    
    # Step 3: Remove OneDrive
    if ($config.RemoveOneDrive) {
        Show-LoadingAnimation "Cleaning up cloud storage" 2
        Remove-OneDrive
        Start-Sleep -Milliseconds 500
    }
    
    # Step 4: Disable telemetry
    if ($config.DisableTelemetry) {
        Show-LoadingAnimation "Enhancing your privacy" 2
        Disable-Telemetry
        Start-Sleep -Milliseconds 500
    }
    
    # Step 5: Services
    if ($config.DisableServices) {
        Show-LoadingAnimation "Stopping background tasks" 2
        Disable-BackgroundServices
        Start-Sleep -Milliseconds 500
    }
    
    # Step 6: Cortana
    if ($config.DisableCortana) {
        Show-LoadingAnimation "Disabling voice assistant" 2
        Disable-CortanaWebSearch
        Start-Sleep -Milliseconds 500
    }
    
    # Step 7: Optimize
    if ($config.OptimizeSystem) {
        Show-LoadingAnimation "Optimizing system settings" 2
        Optimize-System
        Start-Sleep -Milliseconds 500
    }
    
    # Step 8: Clean
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

# Welcome screen with animation
Clear-Host
Write-Host "`n`n`n"

# Animated title
$title = @(
    "        ╔════════════════════════════════════╗",
    "        ║                                    ║",
    "        ║          VELVET DEBLOATER          ║",
    "        ║     Make Your PC Faster & Cleaner  ║",
    "        ║                                    ║",
    "        ╚════════════════════════════════════╝"
)

foreach ($line in $title) {
    Write-Host $line -ForegroundColor $infoColor
    Start-Sleep -Milliseconds 100
}

Write-Host "`n"
Start-Sleep -Milliseconds 500

# Animated dots
Write-Host "        Initializing" -NoNewline -ForegroundColor $infoColor
for ($i = 0; $i -lt 5; $i++) {
    Write-Host "." -NoNewline -ForegroundColor $infoColor
    Start-Sleep -Milliseconds 200
}
Write-Host " Ready!`n" -ForegroundColor $successColor
Start-Sleep -Milliseconds 800

# Simple menu
Clear-Host
Write-Host "`n════════════════════════════════════════" -ForegroundColor $infoColor
Write-Host "  Choose Your Computer Type:" -ForegroundColor $infoColor
Write-Host "════════════════════════════════════════`n" -ForegroundColor $infoColor

Write-Host "  1. 📚 Teacher / Office Work" -ForegroundColor $resetColor
Write-Host "     (Keeps Office & OneDrive, removes games)`n" -ForegroundColor DarkGray

Write-Host "  2. 🎓 Student" -ForegroundColor $resetColor
Write-Host "     (Keeps everything useful for school)`n" -ForegroundColor DarkGray

Write-Host "  3. 🎮 Gaming" -ForegroundColor $resetColor
Write-Host "     (Best for games & Xbox)`n" -ForegroundColor DarkGray

Write-Host "  4. 🏠 Home / Family PC" -ForegroundColor $resetColor
Write-Host "     (Safe for everyone to use)`n" -ForegroundColor DarkGray

Write-Host "  5. 🔥 Maximum Cleanup" -ForegroundColor $resetColor
Write-Host "     (Remove as much as possible)`n" -ForegroundColor DarkGray

Write-Host "════════════════════════════════════════`n" -ForegroundColor $infoColor

Write-Host "Enter a number (1-5): " -ForegroundColor $warningColor -NoNewline
$choice = Read-Host

switch ($choice) {
    1 { Apply-Preset "teacher" }
    2 { Apply-Preset "student" }
    3 { Apply-Preset "gamer" }
    4 { Apply-Preset "home" }
    5 { Apply-Preset "maximum" }
    default {
        Write-Host "`nInvalid choice. Please run the script again." -ForegroundColor $errorColor
        Start-Sleep -Seconds 3
    }
}
