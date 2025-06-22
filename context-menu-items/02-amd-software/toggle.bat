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

:: Path to registry key and its CLSID
set REG_KEY="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
set CLSID={FDADFEE3-02D1-4E7C-A511-380F4C98D73B}

:: If registry key exists in that registry (i.e. already blocked), then remove it, else add it
reg query %REG_KEY% /v %CLSID% >nul 2>&1

if %errorlevel%==0 (
    echo Adding "AMD Software" in context menu...
    reg delete %REG_KEY% /v %CLSID% /f
) else (
    echo Removing "AMD Software" in context menu...
    reg add %REG_KEY% /v %CLSID% /t REG_SZ /d "" /f
)

echo Restart explorer.exe to apply changes
pause
