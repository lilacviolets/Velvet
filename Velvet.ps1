# Requires -RunAsAdministrator

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
# CONFIG
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

$script:Statistics = @{
    RemovedApps = 0
    DisabledServices = 0
    CleanedMB = 0
    TelemetryChanges = 0
}

# ═══════════════════════════════════════════════════════════════════════════════
# HELPERS
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White", [switch]$NoNewline)
    if ($NoNewline) { Write-Host $Message -ForegroundColor $Color -NoNewline }
    else { Write-Host $Message -ForegroundColor $Color }
}

function Write-Step {
    param([string]$StepNumber, [string]$Message)
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    $line = "  │ [$StepNumber] $Message"
    # Make padding safer (avoid negative)
    $maxWidth = 67
    $padLen = $maxWidth - ($line.Length)
    if ($padLen -lt 0) { $padLen = 0 }
    $padding = " " * $padLen
    Write-Host $line$padding -ForegroundColor Cyan
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success { param([string]$Message); Write-Host "        ✓ $Message" -ForegroundColor Green }
function Write-Warning2 { param([string]$Message); Write-Host "        ✗ $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message); Write-Host "        ℹ $Message" -ForegroundColor Gray }

function Test-IsWindows11 {
    try {
        $prop = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuild -ErrorAction Stop
        return ([int]$prop.CurrentBuild -ge 22000)
    } catch {
        return $false
    }
}

# Robust registry setter:
function Invoke-SafeRegistryOperation {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        # If property exists, set it; otherwise create with proper type
        $existing = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        if ($existing -ne $null) {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
        } else {
            New-ItemProperty -Path $Path -Name $Name -PropertyType $Type -Value $Value -Force -ErrorAction Stop | Out-Null
        }
        return $true
    } catch {
        return $false
    }
}

function Read-UserConfirmation {
    param([string]$Prompt, [bool]$DefaultYes = $false)
    if ($Silent) { return $DefaultYes }
    $response = Read-Host $Prompt
    return ($response -in @('Y','y','YES','Yes','yes'))
}

# ═══════════════════════════════════════════════════════════════════════════════
# UI
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
    Write-Host "  │   • System restore point will be created automatically (if able)│" -ForegroundColor White
    Write-Host "  │   • This script modifies system settings and registry           │" -ForegroundColor White
    Write-Host "  │   • Computer restart recommended after completion               │" -ForegroundColor White
    Write-Host "  │   • Backup important data before proceeding                     │" -ForegroundColor White
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
    Write-Host "  │   1. Restart your computer to apply all changes                 │" -ForegroundColor White
    Write-Host "  │   2. Verify that everything works normally                      │" -ForegroundColor White
    Write-Host "  │   3. If issues occur, use System Restore                        │" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  💡 To restore: Control Panel → System → System Protection → System Restore" -ForegroundColor Cyan
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# CORE FUNCTIONS
function New-SystemRestorePoint {
    Write-Step "1/6" "💾 Creating System Restore Point..."
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction Stop | Out-Null
        $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
        $restorePointName = "Velvet_Backup_$timestamp"
        Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop | Out-Null
        Write-Success "Restore point created successfully"
        Write-Info "Name: $restorePointName"
        return $true
    } catch {
        Write-Warning2 "Could not create restore point"
        Write-Info "Reason: $($_.Exception.Message)"
        Write-Host ""
        if (-not $SkipRestorePoint) {
            $continue = Read-UserConfirmation "        ⚠️  Continue without restore point? (Y/N)" -DefaultYes:$false
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
        "Microsoft.3DBuilder","Microsoft.BingNews","Microsoft.BingWeather",
        "Microsoft.BingSports","Microsoft.BingFinance","Microsoft.GetHelp",
        "Microsoft.Getstarted","Microsoft.Messaging","Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection","Microsoft.OneConnect","Microsoft.People",
        "Microsoft.Print3D","Microsoft.SkypeApp","Microsoft.Wallet",
        "Microsoft.WindowsAlarms","Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps",
        "Microsoft.XboxApp","Microsoft.XboxGameOverlay","Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider","Microsoft.ZuneMusic","Microsoft.ZuneVideo",
        "Microsoft.YourPhone","Microsoft.MixedReality.Portal"
    )

    $removedCount = 0
    foreach ($app in $bloatwareApps) {
        try {
            # Remove per-user packages (loop all users' packages)
            $pkgs = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
            foreach ($p in $pkgs) {
                Remove-AppxPackage -Package $p.PackageFullName -ErrorAction SilentlyContinue
                $removedCount++
                Write-Success "Removed: $($p.Name -split '\.' | Select-Object -Last 1)"
            }

            # Remove provisioned package for new users (best-effort)
            $provisioned = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -eq $app -or $_.PackageName -like "*$($app)*" }
            foreach ($prov in $provisioned) {
                Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction SilentlyContinue
            }
        } catch {
            # keep going
        }
    }

    $script:Statistics.RemovedApps = $removedCount
    Write-Host ""
    Write-Success "Attempted to remove $removedCount app packages (per-user). Provisioned packages removed where found."
}

function Disable-TelemetryServices {
    Write-Step "3/6" "🔒 Reducing Telemetry & Diagnostics..."
    $telemetrySuccess = 0

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type "DWord") {
        Write-Success "Telemetry level set to Security (minimum)"
        $telemetrySuccess++
    } else { Write-Warning2 "Could not modify telemetry registry" }

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1 -Type "DWord") {
        Write-Success "Windows Error Reporting disabled"
        $telemetrySuccess++
    } else { Write-Warning2 "Could not disable Error Reporting" }

    try {
        $taskPath = "\Microsoft\Windows\Customer Experience Improvement Program\"
        $tasks = Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue
        $disabledTasks = 0
        foreach ($task in $tasks) {
            try { Disable-ScheduledTask -TaskPath $task.TaskPath -TaskName $task.TaskName -ErrorAction Stop; $disabledTasks++ } catch {}
        }
        if ($disabledTasks -gt 0) { Write-Success "Disabled $disabledTasks CEIP scheduled tasks"; $telemetrySuccess++ }
    } catch { Write-Warning2 "Could not modify scheduled tasks" }

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0 -Type "DWord") {
        Write-Success "Application telemetry disabled"
        $telemetrySuccess++
    } else { Write-Warning2 "Could not disable app telemetry" }

    if (Invoke-SafeRegistryOperation -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type "DWord") {
        Write-Success "Advertising ID disabled"
        $telemetrySuccess++
    }

    $script:Statistics.TelemetryChanges = $telemetrySuccess
    Write-Host ""
    Write-Success "Completed $telemetrySuccess telemetry-related changes (best-effort)"
}

function Disable-UnnecessaryServices {
    Write-Step "4/6" "🚫 Disabling Unnecessary Background Services..."
    $servicesToDisable = @(
        @{Name="DiagTrack"; Display="Connected User Experiences and Telemetry"},
        @{Name="dmwappushservice"; Display="WAP Push Message Routing Service"},
        @{Name="RetailDemo"; Display="Retail Demo Service"}
    )
    $disabledServiceCount = 0
    foreach ($svc in $servicesToDisable) {
        try {
            $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -eq 'Running') { Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue }
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Success "Disabled: $($svc.Display)"
                $disabledServiceCount++
            }
        } catch {
            Write-Warning2 "Could not disable: $($svc.Display)"
        }
    }
    $script:Statistics.DisabledServices = $disabledServiceCount
    Write-Host ""
    Write-Success "Successfully disabled $disabledServiceCount services (where present)"
}

function Clear-TemporaryFiles {
    Write-Step "5/6" "🧹 Cleaning Temporary Files and Cache..."
    $totalCleanedBytes = 0

    try {
        $userTempPath = $env:TEMP
        if (Test-Path $userTempPath) {
            $tempItems = Get-ChildItem -Path $userTempPath -Recurse -File -ErrorAction SilentlyContinue
            $tempSize = ($tempItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($tempSize) { $totalCleanedBytes += $tempSize }
            Remove-Item -Path (Join-Path $userTempPath '*') -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "User temp folder cleaned"
        }
    } catch { Write-Warning2 "Could not clean user temp folder" }

    try {
        $systemTempPath = "$env:SystemRoot\Temp"
        if (Test-Path $systemTempPath) {
            $systemTempItems = Get-ChildItem -Path $systemTempPath -Recurse -File -ErrorAction SilentlyContinue
            $systemTempSize = ($systemTempItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($systemTempSize) { $totalCleanedBytes += $systemTempSize }
            Remove-Item -Path (Join-Path $systemTempPath '*') -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "System temp folder cleaned"
        }
    } catch { Write-Warning2 "Could not clean system temp folder" }

    try {
        $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($wuService) {
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            $downloadPath = "C:\Windows\SoftwareDistribution\Download"
            if (Test-Path $downloadPath) {
                $downloadItems = Get-ChildItem -Path $downloadPath -Recurse -File -ErrorAction SilentlyContinue
                $downloadSize = ($downloadItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                if ($downloadSize) { $totalCleanedBytes += $downloadSize }
                Remove-Item -Path (Join-Path $downloadPath '*') -Recurse -Force -ErrorAction SilentlyContinue
            }
            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
            Write-Success "Windows Update cache cleaned"
        }
    } catch { Write-Warning2 "Could not clean Windows Update cache" }

    try {
        $prefetchPath = "C:\Windows\Prefetch"
        if (Test-Path $prefetchPath) {
            $prefetchItems = Get-ChildItem -Path $prefetchPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -eq '.pf' -or $_.Name -match '\.pf$' }
            $prefetchSize = ($prefetchItems | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            if ($prefetchSize) { $totalCleanedBytes += $prefetchSize }
            Remove-Item -Path (Join-Path $prefetchPath '*.pf') -Force -ErrorAction SilentlyContinue
            Write-Success "Prefetch folder cleaned"
        }
    } catch { Write-Warning2 "Could not clean Prefetch folder" }

    $cleanedMB = 0
    if ($totalCleanedBytes -gt 0) { $cleanedMB = [math]::Round($totalCleanedBytes / 1MB, 2) }
    $script:Statistics.CleanedMB = $cleanedMB
    Write-Host ""
    Write-Success "Total space freed (approx): $cleanedMB MB"
}

function Disable-CortanaAndBing {
    Write-Step "6/6" "🔍 Disabling Cortana and Bing Web Search..."
    $cortanaSuccess = 0

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type "DWord") {
        Write-Success "Cortana disabled"
        $cortanaSuccess++
    } else { Write-Warning2 "Could not disable Cortana" }

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Type "DWord") {
        Write-Success "Web search in Start Menu disabled"
        $cortanaSuccess++
    } else { Write-Warning2 "Could not disable web search" }

    if (Invoke-SafeRegistryOperation -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type "DWord") {
        Write-Success "Bing search integration disabled"
        $cortanaSuccess++
    } else { Write-Warning2 "Could not disable Bing search" }

    if (Invoke-SafeRegistryOperation -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 0 -Type "DWord") {
        Write-Success "Search highlights disabled"
        $cortanaSuccess++
    }

    Write-Host ""
    Write-Success "Completed $cortanaSuccess out of 4 search modifications (best-effort)"
}

function Restart-WindowsExplorer {
    if ($Silent) { return }
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
    Write-Host "  │ 🔄 Restarting Windows Explorer to apply changes...              │" -ForegroundColor Yellow
    Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "This may cause brief screen flickering"
    try {
        # attempt clean restart
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process explorer.exe
        Write-Success "Windows Explorer restarted successfully"
    } catch {
        Write-Warning2 "Could not restart Explorer automatically"
        Write-Info "Please restart manually or reboot your PC"
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
# MAIN
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║   ❌ INCOMPATIBLE VERSION DETECTED   ║" -ForegroundColor Red
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Red
    Write-Host "`nThis script requires PowerShell 3.0 or higher" -ForegroundColor Yellow
    Write-Host "Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
    Exit-Script
}

# Show UI
Show-Header
Show-Features
Show-Warning

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "  │ 🚀 Ready to optimize your system?                               │" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""

# Determine what to run
if (-not $CustomMode) {
    # If user didn't specify switches, default to performing everything unless explicitly set OFF
    if (-not ($CreateRestorePoint -or $RemoveApps -or $DisableTelemetry -or $DisableCortana -or $CleanTemp -or $DisableServices)) {
        # no switches provided -> full run
        $CreateRestorePoint = $true
        $RemoveApps = $true
        $DisableTelemetry = $true
        $DisableCortana = $true
        $CleanTemp = $true
        $DisableServices = $true
    }
}

# Confirm with user (unless silent)
if (-not $Silent) {
    $proceed = Read-UserConfirmation "Proceed with selected operations? (Y/N)" -DefaultYes:$true
    if (-not $proceed) {
        Write-Host ""
        Write-Host "  ╔═══════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║     ❌ OPERATION CANCELLED            ║" -ForegroundColor Red
        Write-Host "  ╚═══════════════════════════════════════╝" -ForegroundColor Red
        Exit-Script
    }
}

# Run steps (wrap each with try so one failure doesn't stop everything)
try {
    if ($CreateRestorePoint) { New-SystemRestorePoint | Out-Null }
} catch {}

try {
    if ($RemoveApps) { Remove-BloatwareApps }
} catch {}

try {
    if ($DisableTelemetry) { Disable-TelemetryServices }
} catch {}

try {
    if ($DisableServices) { Disable-UnnecessaryServices }
} catch {}

try {
    if ($CleanTemp) { Clear-TemporaryFiles }
} catch {}

try {
    if ($DisableCortana) { Disable-CortanaAndBing }
} catch {}

# Summary & cleanup
Show-Summary
Restart-WindowsExplorer
Exit-Script
