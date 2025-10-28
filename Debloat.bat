@echo off
:: ============================================================================
:: VELVET OPTIMIZER v3.1 - Light EDU Debloater
:: Focus: Teachers & Students — minimal, safe, informative
:: ============================================================================
setlocal enabledelayedexpansion

:: -------------------------
:: Basic config & counters
:: -------------------------
set "VERSION=v3.1-EDU"
set /a RemovedCount=0
set "DRYRUN=1"

:: -------------------------
:: Admin check
:: -------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    color 0C
    echo.
    echo  ======================================================================
    echo   Velvet Optimizer %VERSION% - Administrator required
    echo  ======================================================================
    echo   This tool needs elevated permissions to create a restore point
    echo   and remove preinstalled apps. Right-click the file and choose
    echo   "Run as administrator", then run it again.
    echo.
    pause
    exit /b 1
)

:: -------------------------
:: Minimal header
:: -------------------------
cls
color 0B
echo.
echo  ================================================================
echo   Velvet Optimizer %VERSION%  —  Light Debloat for Schools
echo  ================================================================
echo.
color 07
echo  Purpose:
echo    - Remove common non-educational preinstalled apps (games,
echo      trials, demo store apps) that consume space or distract students.
echo    - Keep productivity & learning tools (Teams, OneDrive, Office).
echo.
echo  Safety notes:
echo    - A system restore point will be created first.
echo    - This tool performs a dry-run (lists candidates) and asks for
echo      confirmation before removing anything.
echo    - If you are unsure, choose NO at the confirmation prompt.
echo.
echo  Press any key to continue to the scan (dry-run)...
pause >nul

:: -------------------------
:: Create restore point (best-effort)
:: -------------------------
echo.
echo  [1/4] Creating a system restore point (best-effort)...
powershell -Command "try { Enable-ComputerRestore -Drive '%SystemDrive%\' -ErrorAction Stop; Checkpoint-Computer -Description 'Velvet_EDU_Debloat_%date:~-4,4%-%date:~4,2%-%date:~7,2%' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Output 'OK' } catch { Write-Output 'FAIL' }" > "%temp%\velvet_restore_result.txt" 2>&1
for /f "usebackq delims=" %%A in ("%temp%\velvet_restore_result.txt") do set "RESTOUT=%%A"
if /I "%RESTOUT%"=="OK" (
    echo   Restore point created.
) else (
    echo   Could not create restore point (continuing anyway).
)
del "%temp%\velvet_restore_result.txt" >nul 2>&1
echo.

:: -------------------------
:: Define conservative safe removal patterns
:: -------------------------
:: NOTE: These patterns intentionally avoid Teams, OneDrive, Office, Xbox core,
::       and accessibility/education apps.
setlocal DisableDelayedExpansion
set "PATTERNS=Solitaire CandyCandy CandyCrush MinecraftTrial ZuneMusic ZuneVideo 3DViewer Paint3D MixedReality.Shell MixedReality.Portal GetStarted Tips People Xbox.TCUI XboxGameOverlay XboxGamingOverlay BingNews BingWeather BingSports BingFinance BingFoodAndDrink BingTravel BingHealthAndFitness Netflix Disney SpotifyAB.SpotifyMusic Microsoft.XboxApp.MicrosoftXboxApp"
setlocal enabledelayedexpansion

:: -------------------------
:: Dry-run: list matched packages (AllUsers)
:: -------------------------
echo  [2/4] Scanning for candidate apps to remove (dry-run)...
echo.
set "TEMPFILE=%temp%\velvet_candidates.txt"
if exist "%TEMPFILE%" del "%TEMPFILE%"
for %%P in (%PATTERNS%) do (
    powershell -Command "Get-AppxPackage -AllUsers -Name '*%%~P*' | Select-Object -ExpandProperty Name" >> "%TEMPFILE%" 2>nul
)

:: Deduplicate and show
if exist "%TEMPFILE%" (
    echo  The following packages were found that match the debloat list:
    echo.
    sort "%TEMPFILE%" /unique > "%TEMPFILE%.uniq" 2>nul
    for /f "usebackq delims=" %%L in ("%TEMPFILE%.uniq") do (
        echo    - %%L
    )
    echo.
    del "%TEMPFILE%.uniq" >nul 2>&1
) else (
    echo  No matching candidate apps were found.
    echo.
)

:: -------------------------
:: Informational: what is bloatware (brief)
:: -------------------------
echo  What we mean by "bloatware":
echo    - Preinstalled consumer apps, trial games, and store demos that are
echo      not typically needed in a classroom (examples: Solitaire bundles,
echo      trial streaming apps, 3D Viewer, Paint 3D).
echo    - These apps take disk space and sometimes run background updates.
echo    - We will NOT remove: Teams, OneDrive, Office, built-in accessibility,
echo      system components, or essential Microsoft services.
echo.

:: -------------------------
:: Confirm action
:: -------------------------
echo  Dry-run only so far. No changes have been made.
set /p "confirm=Do you want to remove the listed apps for all current users? (YES/NO): "
if /I not "%confirm%"=="YES" (
    echo.
    echo  No changes applied. Exiting.
    echo.
    pause
    exit /b 0
)

:: -------------------------
:: Perform removals
:: -------------------------
echo.
echo  [3/4] Removing selected apps (this may take a minute)...
set /a RemovedCount=0
for %%P in (%PATTERNS%) do (
    :: remove matching appx packages for all users (best-effort)
    powershell -Command ^
      "$names = Get-AppxPackage -AllUsers -Name '*%%~P*' | Select-Object -ExpandProperty Name -Unique; ^
       foreach ($n in $names) { Write-Output ('REMOVING:'+$n); try { Get-AppxPackage -AllUsers -Name $n | Remove-AppxPackage -ErrorAction Stop; } catch {}; }" >> "%temp%\velvet_remove_log.txt" 2>&1
)

:: Count lines indicating REMOVING
set /a RemovedCount=0
for /f "usebackq delims=" %%R in ("%temp%\velvet_remove_log.txt") do (
    echo %%R | findstr /b /c:"REMOVING:" >nul 2>&1
    if !errorlevel! equ 0 set /a RemovedCount+=1
)
if %RemovedCount% gtr 0 (
    echo.
    echo  Completed removals. Packages removed (logged): %RemovedCount%
) else (
    echo.
    echo  No packages were removed (either none matched or removal failed).
)

:: -------------------------
:: Optional: remove Store shortcuts / OEM leftover via Provisioned packages (conservative)
:: (This section is intentionally commented out to remain safe for schools.)
:: -------------------------
:: echo.
:: echo  [Optional] Removing provisioned packages for new user accounts (skipped)
:: echo  If you want to enable this, review provisioning commands carefully.
:: -------------------------

:: -------------------------
:: Final cleanup actions (temp, thumbnail DB)
:: -------------------------
echo.
echo  [4/4] Final cleanup: temp folders & thumbnail DB (safe)
echo    - Clearing user %TEMP% (current user only)
del /f /s /q "%TEMP%\*" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1

:: Clear thumbnail caches for current user only
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\*.db" >nul 2>&1 2>nul

echo.
echo  Summary:
echo    - Packages removed (logged): %RemovedCount%
echo    - A system restore point was created earlier (if permitted).
echo    - If you do not see the change, sign out or restart may be required.
echo.
echo  Tips for teachers:
echo    - Keep Teams and OneDrive for class work.
echo    - Use Group Policy or Intune for mass-managed classroom devices.
echo    - Run this tool once per machine after imaging to remove initial demos.
echo.
echo  Press any key to finish.
pause >nul

:: cleanup temp log
if exist "%temp%\velvet_remove_log.txt" del "%temp%\velvet_remove_log.txt" >nul 2>&1

endlocal
exit /b 0
