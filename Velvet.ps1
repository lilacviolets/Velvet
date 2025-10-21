# ═══════════════════════════════════════════════════════════════════════════════
#  ██╗   ██╗███████╗██╗     ██╗   ██╗███████╗████████╗
#  ██║   ██║██╔════╝██║     ██║   ██║██╔════╝╚══██╔══╝
#  ██║   ██║█████╗  ██║     ██║   ██║█████╗     ██║   
#  ╚██╗ ██╔╝██╔══╝  ██║     ╚██╗ ██╔╝██╔══╝     ██║   
#   ╚████╔╝ ███████╗███████╗ ╚████╔╝ ███████╗   ██║   
#    ╚═══╝  ╚══════╝╚══════╝  ╚═══╝  ╚══════╝   ╚═╝   
#
#  Advanced Windows System Optimization & Cleanup Tool
#  Educational Project - School Exhibition 2025
#  Created by: lilacviolets!!
# ═══════════════════════════════════════════════════════════════════════════════
#
#  ⚠️  DISCLAIMER: Educational purposes only. Always backup your data.
#  📋 Requires: PowerShell 3.0+ and Administrator privileges
#
# ═══════════════════════════════════════════════════════════════════════════════

#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$Silent,
    [switch]$CustomMode,
    [switch]$CreateRestorePoint,
    [switch]$RemoveApps,
    [switch]$DisableTelemetry,
    [switch]$DisableCortana,
    [switch]$CleanTemp,
    [switch]$DisableServices,
    [switch]$SkipRestorePoint
)

# ═══════════════════════════════════════════════════════════════════════════════
# ⚙️  CONFIGURATION & GLOBAL VARIABLES
# ═══════════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

$script:Statistics = @{
    RemovedApps = 0
    DisabledServices = 0
    CleanedMB = 0
    TelemetryChanges = 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔧 HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    
    if ($NoNewline) {
        Write-Host $Message -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Write-Step {
    param(
        [string]$StepNumber,
        [string]$Message
    )
    
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │ [$StepNumber] $Message" -ForegroundColor Cyan
    $padding = " " * (66 - $Message.Length)
    Write-Host "  │$padding│" -ForegroundColor Cyan
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "        ✓ $Message" -ForegroundColor Green
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "        ✗ $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "        ℹ $Message" -ForegroundColor Gray
}

function Test-IsWindows11 {
    $WinVersion = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' CurrentBuild -ErrorAction SilentlyContinue
    return ($WinVersion -ge 22000)
}

function Invoke-SafeRegistryOperation {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )
    
    try {
        if (-not (Test-Path $Path)) {
            $null = New-Item -Path $Path -Force -ErrorAction Stop
        }
        $null = Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Read-UserConfirmation {
    param(
        [string]$Prompt,
        [string]$DefaultYes = $false
    )
    
    if ($Silent) {
        return $DefaultYes
    }
    
    $response = Read-Host $Prompt
    return ($response -eq 'YES' -or $response -eq 'yes' -or $response -eq 'Y' -or $response -eq 'y')
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🎨 UI DISPLAY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                                                                   ║" -ForegroundColor Cyan
    Write-Host "  ║          ██╗   ██╗███████╗██╗     ██╗   ██╗███████╗████████╗    ║" -ForegroundColor Magenta
    Write-Host "  ║          ██║   ██║██╔════╝██║     ██║   ██║██╔════╝╚══██╔══╝    ║" -ForegroundColor Magenta
    Write-Host "  ║          ██║   ██║█████╗  ██║     ██║   ██║█████╗     ██║       ║" -ForegroundColor Magenta
    Write-Host "  ║          ╚██╗ ██╔╝██╔══╝  ██║     ╚██╗ ██╔╝██╔══╝     ██║       ║" -ForegroundColor Magenta
    Write-Host "  ║           ╚████╔╝ ███████╗███████╗ ╚████╔╝ ███████╗   ██║       ║" -ForegroundColor Magenta
    Write-Host "  ║            ╚═══╝  ╚══════╝╚══════╝  ╚═══╝  ╚══════╝   ╚═╝       ║" -ForegroundColor Magenta
    Write-Host "  ║                                                                   ║" -ForegroundColor Cyan
    Write-Host "  ║              Advanced Windows System Optimization                 ║" -ForegroundColor White
    Write-Host "  ║                  School Exhibition Project 2025                   ║" -ForegroundColor Gray
    Write-Host "  ║                                                                   ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Features {
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │ 🎯 OPTIMIZATION FEATURES:                                       │" -ForegroundColor White
    Write-Host "  ├─────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkGray
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  │   📦 Remove pre-installed bloatware applications                │" -ForegroundColor Gray
    Write-Host "  │   🔒 Reduce telemetry and data collection                       │" -ForegroundColor Gray
    Write-Host "  │   🧹 Clean temporary and cache files                            │" -ForegroundColor Gray
    Write-Host "  │   🚫 Disable unnecessary background services                    │" -ForegroundColor Gray
    Write-Host "  │   🔍 Disable Cortana and Bing web search                        │" -ForegroundColor Gray
    Write-Host "  │   💾 Create system restore point before changes                 │" -ForegroundColor Gray
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-Warning {
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "  │ ⚠️  IMPORTANT SAFETY INFORMATION:                               │" -ForegroundColor Yellow
    Write-Host "  ├─────────────────────────────────────────────────────────────────┤" -ForegroundColor Yellow
    Write-Host "  │                                                                 │" -ForegroundColor Yellow
    Write-Host "  │   • System restore point will be created automatically          │" -ForegroundColor White
    Write-Host "  │   • This script modifies system settings and registry           │" -ForegroundColor White
    Write-Host "  │   • Computer restart recommended after completion               │" -ForegroundColor White
    Write-Host "  │   • Backup important data before proceeding                     │" -ForegroundColor White
    Write-Host "  │   • Changes can be reverted via System Restore                  │" -ForegroundColor White
    Write-Host "  │                                                                 │" -ForegroundColor Yellow
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
}

function Show-Summary {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                    ✓ CLEANUP COMPLETE!                            ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  📊 SUMMARY:" -ForegroundColor White
    Write-Host "  ├─────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  │   • Removed apps: $($script:Statistics.RemovedApps)" -ForegroundColor Gray
    Write-Host "  │   • Disabled services: $($script:Statistics.DisabledServices)" -ForegroundColor Gray
    Write-Host "  │   • Space freed: $($script:Statistics.CleanedMB) MB" -ForegroundColor Gray
    Write-Host "  │   • Telemetry changes: $($script:Statistics.TelemetryChanges)" -ForegroundColor Gray
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ⚡ NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  ├─────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  │   1. Restart your computer to apply all changes                 │" -ForegroundColor White
    Write-Host "  │   2. Verify that everything works normally                      │" -ForegroundColor White
    Write-Host "  │   3. If issues occur, use System Restore                        │" -ForegroundColor White
    Write-Host "  │                                                                 │" -ForegroundColor DarkGray
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  💡 To restore: Control Panel → System → System Protection → System Restore" -ForegroundColor Cyan
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🔨 CORE FUNCTIONALITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function New-SystemRestorePoint {
    Write-Step "1/6" "💾 Creating System Restore Point..."
    
    try {
        $null = Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop
        
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
        $restorePointName = "Velvet_Backup_$timestamp"
        
        Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        Write-Success "Restore point created successfully"
        Write-Info "Name: $restorePointName"
        return $true
    } catch {
        Write-Warning2 "Could not create restore point"
        Write-Info "Reason: $($_.Exception.Message)"
        Write-Host ""
        
        if (-not $SkipRestorePoint) {
            $continue = Read-UserConfirmation "        ⚠️  Continue without restore point? (Y/N)" -DefaultYes $false
            
            if (-not $continue) {
                Write-Host ""
                Write-Host "  ╔═══════════════════════════════════════╗" -ForegroundColor Red
                Write-Host "  ║     ❌ OPERATION CANCELLED            ║" -ForegroundColor Red
                Write-Host "  ╚═══════════════════════════════════════╝" -ForegroundColor Red
                Write-Host ""
                Exit-Script
            }
        }
        
        return $false
    }
}

function Remove-BloatwareApps {
    Write-Step "2/6" "📦 Removing Bloatware Applications..."
    
    $bloatwareApps = @(
        "Microsoft.3DBuilder",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.BingSports",
        "Microsoft.BingFinance",
        "Microsoft.GetHelp",
        "Microsoft.Getstarted",
        "Microsoft.Messaging",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.Print3D",
        "Microsoft.SkypeApp",
        "Microsoft.Wallet",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.WindowsMaps",
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.YourPhone",
        "Microsoft.MixedReality.Portal"
    )
    
    $removedCount = 0
    $totalApps = $bloatwareApps.Count
    
    foreach ($app in $bloatwareApps) {
        try {
            # Remove for current user
            $package = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            if ($package) {
                $null = Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Stop
                $appDisplayName = $app.Split('.')[-1]
                Write-Success "Removed: $appDisplayName"
                $removedCount++
            }
            
            # Remove for all users
            $packageAllUsers = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
            if ($packageAllUsers) {
                $null = Remove-AppxPackage -Package $packageAllUsers.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            }
            
            # Remove provisioned package
            $provisionedPkg = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -eq $app }
            if ($provisionedPkg) {
                $null = Remove-AppxProvisionedPackage -Online -PackageName $provisionedPkg.PackageName -ErrorAction SilentlyContinue
            }
        } catch {
            # Silently continue on errors
        }
    }
    
    $script:Statistics.RemovedApps = $removedCount
    
    Write-Host ""
    Write-Success "Successfully removed $removedCount out of $totalApps apps"
}

function Disable-TelemetryServices {
    Write-Step "3/6" "🔒 Reducing Telemetry & Diagnostics..."
    
    $telemetrySuccess = 0
    
    # Configure telemetry registry settings
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0) {
        Write-Success "Telemetry level set to Security (minimum)"
        $telemetrySuccess++
    } else {
        Write-Warning2 "Could not modify telemetry registry"
    }
    
    # Disable Windows Error Reporting
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1) {
        Write-Success "Windows Error Reporting disabled"
        $telemetrySuccess++
    } else {
        Write-Warning2 "Could not disable Error Reporting"
    }
    
    # Disable CEIP scheduled tasks
    try {
        $taskPath = "\Microsoft\Windows\Customer Experience Improvement Program\"
        $tasks = Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue
        $disabledTasks = 0
        foreach ($task in $tasks) {
            try {
                $null = Disable-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction Stop
                $disabledTasks++
            } catch {}
        }
        if ($disabledTasks -gt 0) {
            Write-Success "Disabled $disabledTasks CEIP scheduled tasks"
            $telemetrySuccess++
        }
    } catch {
        Write-Warning2 "Could not modify scheduled tasks"
    }
    
    # Disable Application Telemetry
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0) {
        Write-Success "Application telemetry disabled"
        $telemetrySuccess++
    } else {
        Write-Warning2 "Could not disable app telemetry"
    }
    
    # Disable Advertising ID
    if (Invoke-SafeRegistryOperation -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0) {
        Write-Success "Advertising ID disabled"
        $telemetrySuccess++
    }
    
    $script:Statistics.TelemetryChanges = $telemetrySuccess
    
    Write-Host ""
    Write-Success "Completed $telemetrySuccess out of 5 telemetry changes"
}

function Disable-UnnecessaryServices {
    Write-Step "4/6" "🚫 Disabling Unnecessary Background Services..."
    
    $servicesToDisable = @(
        @{Name="DiagTrack"; Display="Connected User Experiences and Telemetry"},
        @{Name="dmwappushservice"; Display="WAP Push Message Routing Service"},
        @{Name="RetailDemo"; Display="Retail Demo Service"}
    )
    
    $disabledServiceCount = 0
    $totalServices = $servicesToDisable.Count
    
    foreach ($svc in $servicesToDisable) {
        try {
            $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -eq 'Running') {
                    $null = Stop-Service -Name $svc.Name -Force -ErrorAction Stop
                }
                $null = Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-Success "Disabled: $($svc.Display)"
                $disabledServiceCount++
            }
        } catch {
            Write-Warning2 "Could not disable: $($svc.Display)"
        }
    }
    
    $script:Statistics.DisabledServices = $disabledServiceCount
    
    Write-Host ""
    Write-Success "Successfully disabled $disabledServiceCount out of $totalServices services"
}

function Clear-TemporaryFiles {
    Write-Step "5/6" "🧹 Cleaning Temporary Files and Cache..."
    
    $totalCleanedBytes = 0
    
    # Clean user temp folder
    try {
        $userTempPath = $env:TEMP
        if (Test-Path $userTempPath) {
            $tempItems = Get-ChildItem -Path $userTempPath -Recurse -File -ErrorAction SilentlyContinue
            $tempSize = ($tempItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($tempSize) {
                $totalCleanedBytes += $tempSize
            }
            $null = Remove-Item -Path "$userTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "User temp folder cleaned"
        }
    } catch {
        Write-Warning2 "Could not clean user temp folder"
    }
    
    # Clean system temp folder
    try {
        $systemTempPath = "$env:SystemRoot\Temp"
        if (Test-Path $systemTempPath) {
            $systemTempItems = Get-ChildItem -Path $systemTempPath -Recurse -File -ErrorAction SilentlyContinue
            $systemTempSize = ($systemTempItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($systemTempSize) {
                $totalCleanedBytes += $systemTempSize
            }
            $null = Remove-Item -Path "$systemTempPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "System temp folder cleaned"
        }
    } catch {
        Write-Warning2 "Could not clean system temp folder"
    }
    
    # Clean Windows Update cache
    try {
        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($wuService) {
            $null = Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            $downloadPath = "C:\Windows\SoftwareDistribution\Download"
            if (Test-Path $downloadPath) {
                $downloadItems = Get-ChildItem -Path $downloadPath -Recurse -File -ErrorAction SilentlyContinue
                $downloadSize = ($downloadItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                if ($downloadSize) {
                    $totalCleanedBytes += $downloadSize
                }
                $null = Remove-Item -Path "$downloadPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            $null = Start-Service -Name wuauserv -ErrorAction SilentlyContinue
            Write-Success "Windows Update cache cleaned"
        }
    } catch {
        Write-Warning2 "Could not clean Windows Update cache"
    }
    
    # Clean Windows Prefetch
    try {
        $prefetchPath = "C:\Windows\Prefetch"
        if (Test-Path $prefetchPath) {
            $prefetchItems = Get-ChildItem -Path $prefetchPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq '.pf' }
            $prefetchSize = ($prefetchItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($prefetchSize) {
                $totalCleanedBytes += $prefetchSize
            }
            $null = Remove-Item -Path "$prefetchPath\*.pf" -Force -ErrorAction SilentlyContinue
            Write-Success "Prefetch folder cleaned"
        }
    } catch {
        Write-Warning2 "Could not clean Prefetch folder"
    }
    
    # Calculate total cleaned space
    $cleanedMB = 0
    $cleanedGB = 0
    if ($totalCleanedBytes -gt 0) {
        $cleanedMB = [math]::Round($totalCleanedBytes / 1MB, 2)
        $cleanedGB = [math]::Round($totalCleanedBytes / 1GB, 2)
    }
    
    $script:Statistics.CleanedMB = $cleanedMB
    
    Write-Host ""
    if ($cleanedGB -ge 1) {
        Write-Success "Total space freed: $cleanedGB GB ($cleanedMB MB)"
    } else {
        Write-Success "Total space freed: $cleanedMB MB"
    }
}

function Disable-CortanaAndBing {
    Write-Step "6/6" "🔍 Disabling Cortana and Bing Web Search..."
    
    $cortanaSuccess = 0
    
    # Disable Cortana
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0) {
        Write-Success "Cortana disabled"
        $cortanaSuccess++
    } else {
        Write-Warning2 "Could not disable Cortana"
    }
    
    # Disable web search in Start Menu
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1) {
        Write-Success "Web search in Start Menu disabled"
        $cortanaSuccess++
    } else {
        Write-Warning2 "Could not disable web search"
    }
    
    # Disable Bing search in Start Menu
    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0) {
        Write-Success "Bing search integration disabled"
        $cortanaSuccess++
    } else {
        Write-Warning2 "Could not disable Bing search"
    }
    
    # Disable search highlights
    if (Invoke-SafeRegistryOperation -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 0) {
        Write-Success "Search highlights disabled"
        $cortanaSuccess++
    }
    
    Write-Host ""
    Write-Success "Completed $cortanaSuccess out of 4 search modifications"
}

function Restart-WindowsExplorer {
    if ($Silent) {
        return
    }
    
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "  │ 🔄 Restarting Windows Explorer to apply changes...              │" -ForegroundColor Yellow
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Info "This may cause brief screen flickering"
    
    # Only restart if the PowerShell process matches the OS architecture
    if ([Environment]::Is64BitProcess -eq [Environment]::Is64BitOperatingSystem) {
        try {
            Stop-Process -Name Explorer -Force -ErrorAction Stop
            Start-Sleep -Seconds 2
            Write-Success "Windows Explorer restarted successfully"
        } catch {
            Write-Warning2 "Could not restart Explorer automatically"
            Write-Info "Please restart manually or reboot your PC"
        }
    } else {
        Write-Warning2 "Architecture mismatch detected"
        Write-Info "Please manually reboot your PC to apply all changes"
    }
}

function Exit-Script {
    Write-Host ""
    
    if (-not $Silent) {
        Write-Host "  Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    exit
}

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

# Check PowerShell version compatibility
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   ❌ INCOMPATIBLE VERSION DETECTED   ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Red
    Write-Host "`nThis script requires PowerShell 3.0 or higher" -ForegroundColor Yellow
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
    Exit-Script
}

# Display UI
Show-Header
Show-Features
Show-Warning

# User confirmation
Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "  │ 🚀 Ready to optimize your system?                               │" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host
