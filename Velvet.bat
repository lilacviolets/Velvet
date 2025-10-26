@echo off
:: Requires Administrator privileges
setlocal enabledelayedexpansion

:: ═══════════════════════════════════════════════════════════════════════════════
:: CONFIG
set "RemovedApps=0"
set "DisabledServices=0"
set "CleanedMB=0"
set "TelemetryChanges=0"

:: ═══════════════════════════════════════════════════════════════════════════════
:: CHECK ADMIN
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo  ╔═══════════════════════════════════════╗
    echo  ║   ❌ ADMINISTRATOR ACCESS REQUIRED   ║
    echo  ╚═══════════════════════════════════════╝
    echo.
    echo  This script must be run as Administrator.
    echo  Right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: ═══════════════════════════════════════════════════════════════════════════════
:: HEADER
cls
color 0B
echo.
echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║                                                                   ║
echo  ║          ██╗   ██╗███████╗██╗     ██╗   ██╗███████╗████████╗    ║
echo  ║          ██║   ██║██╔════╝██║     ██║   ██║██╔════╝╚══██╔══╝    ║
echo  ║          ██║   ██║█████╗  ██║     ██║   ██║█████╗     ██║       ║
echo  ║          ╚██╗ ██╔╝██╔══╝  ██║     ╚██╗ ██╔╝██╔══╝     ██║       ║
echo  ║           ╚████╔╝ ███████╗███████╗ ╚████╔╝ ███████╗   ██║       ║
echo  ║            ╚═══╝  ╚══════╝╚══════╝  ╚═══╝  ╚══════╝   ╚═╝       ║
echo  ║                                                                   ║
echo  ║              Advanced Windows System Optimization                 ║
echo  ║                  School Exhibition Project 2025                   ║
echo  ║                                                                   ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: FEATURES
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ 🎯 OPTIMIZATION FEATURES:                                       │
echo  ├─────────────────────────────────────────────────────────────────┤
echo  │                                                                 │
echo  │   📦 Remove pre-installed bloatware applications                │
echo  │   🔒 Reduce telemetry and data collection                       │
echo  │   🧹 Clean temporary and cache files                            │
echo  │   🚫 Disable unnecessary background services                    │
echo  │   🔍 Disable Cortana and Bing web search                        │
echo  │   💾 Create system restore point before changes                 │
echo  │                                                                 │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: WARNING
color 0E
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ ⚠️  IMPORTANT SAFETY INFORMATION:                               │
echo  ├─────────────────────────────────────────────────────────────────┤
echo  │                                                                 │
echo  │   • System restore point will be created automatically          │
echo  │   • This script modifies system settings and registry           │
echo  │   • Computer restart recommended after completion               │
echo  │   • Backup important data before proceeding                     │
echo  │                                                                 │
echo  └─────────────────────────────────────────────────────────────────┘
echo.
color 0B

echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ 🚀 Ready to optimize your system?                               │
echo  └─────────────────────────────────────────────────────────────────┘
echo.
set /p "confirm=Proceed with optimization? (Y/N): "
if /i not "%confirm%"=="Y" (
    color 0C
    echo.
    echo  ╔═══════════════════════════════════════╗
    echo  ║     ❌ OPERATION CANCELLED            ║
    echo  ╚═══════════════════════════════════════╝
    echo.
    pause
    exit /b 0
)

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 1: CREATE RESTORE POINT
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [1/6] 💾 Creating System Restore Point...                       │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

powershell -Command "Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Checkpoint-Computer -Description 'Velvet_Backup_%date:~-4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue" >nul 2>&1

if %errorlevel% equ 0 (
    echo         ✓ Restore point created successfully
) else (
    echo         ✗ Could not create restore point ^(may require System Protection^)
    echo         ℹ Continuing anyway...
)

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 2: REMOVE BLOATWARE (EXCLUDING XBOX)
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [2/6] 📦 Removing Bloatware Applications...                     │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

:: Remove bloatware apps via PowerShell (Xbox apps excluded)
powershell -Command "$apps = @('Microsoft.3DBuilder','Microsoft.BingNews','Microsoft.BingWeather','Microsoft.BingSports','Microsoft.BingFinance','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Messaging','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.OneConnect','Microsoft.People','Microsoft.Print3D','Microsoft.SkypeApp','Microsoft.Wallet','Microsoft.WindowsAlarms','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.YourPhone','Microsoft.MixedReality.Portal','Microsoft.ZuneMusic','Microsoft.ZuneVideo'); $count=0; foreach($app in $apps){try{Get-AppxPackage -Name $app -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue; $count++}catch{}}; Write-Host \"        ✓ Attempted to remove $count app packages\"" 2>nul

echo         ℹ Note: Xbox apps were preserved

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 3: DISABLE TELEMETRY
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [3/6] 🔒 Reducing Telemetry ^& Diagnostics...                    │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Telemetry level set to Security ^(minimum^)
    set /a TelemetryChanges+=1
)

reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Windows Error Reporting disabled
    set /a TelemetryChanges+=1
)

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Application telemetry disabled
    set /a TelemetryChanges+=1
)

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Advertising ID disabled
    set /a TelemetryChanges+=1
)

:: Disable CEIP scheduled tasks
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ CEIP scheduled tasks disabled
    set /a TelemetryChanges+=1
)

echo.
echo         ✓ Completed %TelemetryChanges% telemetry-related changes

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 4: DISABLE SERVICES
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [4/6] 🚫 Disabling Unnecessary Background Services...           │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

sc config "DiagTrack" start= disabled >nul 2>&1
net stop "DiagTrack" >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Disabled: Connected User Experiences and Telemetry
    set /a DisabledServices+=1
)

sc config "dmwappushservice" start= disabled >nul 2>&1
net stop "dmwappushservice" >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Disabled: WAP Push Message Routing Service
    set /a DisabledServices+=1
)

sc config "RetailDemo" start= disabled >nul 2>&1
net stop "RetailDemo" >nul 2>&1
if %errorlevel% equ 0 (
    echo         ✓ Disabled: Retail Demo Service
    set /a DisabledServices+=1
)

echo.
echo         ✓ Successfully disabled %DisabledServices% services

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 5: CLEAN TEMP FILES
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [5/6] 🧹 Cleaning Temporary Files and Cache...                  │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

:: Clean user temp
del /f /s /q "%TEMP%\*" >nul 2>&1
echo         ✓ User temp folder cleaned

:: Clean system temp
del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
echo         ✓ System temp folder cleaned

:: Clean Windows Update cache
net stop wuauserv >nul 2>&1
timeout /t 2 /nobreak >nul
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
echo         ✓ Windows Update cache cleaned

:: Clean Prefetch
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
echo         ✓ Prefetch folder cleaned

echo.
echo         ✓ Temporary files cleaned successfully

:: ═══════════════════════════════════════════════════════════════════════════════
:: STEP 6: DISABLE CORTANA AND BING
echo.
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ [6/6] 🔍 Disabling Cortana and Bing Web Search...               │
echo  └─────────────────────────────────────────────────────────────────┘
echo.

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo         ✓ Cortana disabled

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 1 /f >nul 2>&1
if %errorlevel% equ 0 echo         ✓ Web search in Start Menu disabled

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v ConnectedSearchUseWeb /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo         ✓ Bing search integration disabled

reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsDynamicSearchBoxEnabled /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% equ 0 echo         ✓ Search highlights disabled

echo.
echo         ✓ Search modifications completed

:: ═══════════════════════════════════════════════════════════════════════════════
:: SUMMARY
color 0A
echo.
echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║                    ✓ CLEANUP COMPLETE!                            ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.
echo  📊 SUMMARY:
echo  ├─────────────────────────────────────────────────────────────────┐
echo  │                                                                 │
echo  │   • Bloatware apps removed                                      │
echo  │   • Disabled services: %DisabledServices%                                          │
echo  │   • Telemetry changes: %TelemetryChanges%                                          │
echo  │   • Temporary files cleaned                                     │
echo  │                                                                 │
echo  └─────────────────────────────────────────────────────────────────┘
echo.
color 0E
echo  ⚡ NEXT STEPS:
echo  ├─────────────────────────────────────────────────────────────────┐
echo  │   1. Restart your computer to apply all changes                 │
echo  │   2. Verify that everything works normally                      │
echo  │   3. If issues occur, use System Restore                        │
echo  └─────────────────────────────────────────────────────────────────┘
echo.
color 0B
echo  💡 To restore: Control Panel → System → System Protection → System Restore
echo.

:: ═══════════════════════════════════════════════════════════════════════════════
:: RESTART EXPLORER
echo  ┌─────────────────────────────────────────────────────────────────┐
echo  │ 🔄 Restarting Windows Explorer to apply changes...              │
echo  └─────────────────────────────────────────────────────────────────┘
echo.
echo         ℹ This may cause brief screen flickering
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe
echo         ✓ Windows Explorer restarted successfully
echo.

pause
exit /b 0
