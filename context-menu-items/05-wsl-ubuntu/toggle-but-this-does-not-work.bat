@echo off

:: Ensure file is executed as admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
) else (
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
)

:: Path to registry key
set BG_REG_KEY=HKEY_CLASSES_ROOT\Directory\Background\shell\WSL
set DIR_REG_KEY=HKEY_CLASSES_ROOT\Directory\shell\WSL

:: If registry key exists in that registry, then remove it, else add it + the "\command" sub-registry key
reg query "%BG_REG_KEY%" >nul 2>&1
set TEXT=Open WSL (Ubuntu) here

if %errorlevel%==0 (
    echo Removing "%TEXT%" from context menu...
    reg delete "%BG_REG_KEY%" /f
    reg delete "%DIR_REG_KEY%" /f
) else (
    echo Adding "%TEXT%" to context menu...

    :: Background
    reg add "%BG_REG_KEY%"         /ve /d "%TEXT%" /f
    reg add "%BG_REG_KEY%"         /v "Icon" /d "C:\Program Files\WSL\wsl.exe" /f
    reg add "%BG_REG_KEY%\command" /ve /d "\"C:\Program Files\WSL\wsl.exe\" --cd \"%%V\"" /f

    :: Directory
    reg add "%DIR_REG_KEY%"         /ve /d "%TEXT%" /f
    reg add "%DIR_REG_KEY%"         /v "Icon" /d "C:\Program Files\WSL\wsl.exe" /f
    reg add "%DIR_REG_KEY%\command" /ve /d "\"C:\Program Files\WSL\wsl.exe\" --cd \"%%V\"" /f
)

pause
