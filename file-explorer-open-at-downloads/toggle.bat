@echo off
setlocal enabledelayedexpansion

:: Ensure .reg files exist
if not exist "./Enable.reg" (
    echo ERROR: "Enable.reg" file not found!
    pause
    exit /b
)

if not exist "./Disable.reg" (
    echo ERROR: "Disable.reg" file not found!
    pause
    exit /b
)

:: Path to registry key
set REG_KEY="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

:: Get current value of "LaunchTo"
reg query %REG_KEY% /v LaunchTo > nul 2>&1

:: Check if "LaunchTo" value exists
if errorlevel 1 (
    echo "LaunchTo" subkey not found in registry, defaulting to "Enable.reg"...
    goto enable
)

:: Assign variable with the current "LaunchTo" value
for /f "tokens=3" %%a in ('reg query %REG_KEY% /v LaunchTo ^| find "LaunchTo"') do (
    set value=%%a
)

:: Toggle "value" variable
if "!value!"=="0x1" (
    echo File Explorer currently opens at "This PC", changing to "Downloads"...
    reg import Enable.reg
)

if "!value!"=="0x3" (
    echo File Explorer currently opens at "Downloads", changing to "This PC"...
    reg import Disable.reg
)

if not "!value!"=="0x1" if not "!value!"=="0x3" (
    echo Unknown "LaunchTo" value: !value!
)

pause
exit /b
