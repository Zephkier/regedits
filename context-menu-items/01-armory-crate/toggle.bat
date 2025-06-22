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
set REG_KEY="HKEY_CLASSES_ROOT\Directory\Background\shell\GameLibrary"

:: If registry key exists in that registry, then remove it, else add it
reg query %REG_KEY% >nul 2>&1

if %errorlevel%==0 (
    echo Removing "Armoury Crate" from context menu...
    reg delete %REG_KEY% /f
) else (
    echo Adding "Armoury Crate" to context menu...
    reg add %REG_KEY% /ve /d "" /f
    reg add %REG_KEY% /v "MUIVerb" /d "ArmouryCrate" /f
    reg add %REG_KEY% /v "SubCommands" /d "g0;|;g1;g2;g3;" /f
    reg add %REG_KEY% /v "Icon" /d "C:\\Users\\benja\\AppData\\Local\\Packages\\B9ECED6F.ArmouryCrate_qmba6cd70vzyy\\LocalState\\GameLibrary\\ArmouryCrate.ico" /f
)

echo Restart explorer.exe to apply changes
pause
