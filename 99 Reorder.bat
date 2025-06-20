@echo off
setlocal enabledelayedexpansion

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

:: Registry base paths
set BG_BASE=HKEY_CLASSES_ROOT\Directory\Background\shell
set DIR_BASE=HKEY_CLASSES_ROOT\Directory\shell

:: Key names in Reg Edit
set ITEM1=Search Everything...
set ITEM2=PowerShell7
set ITEM3=WSL
set ITEM4=VSCode
set ITEM5=AnyCode
set ITEM6=git_gui
set ITEM7=git_shell

:: Detect state based on "Search Everything..." only
set STATE=UNKNOWN

reg query "%BG_BASE%\%ITEM1%" >nul 2>&1
if %errorlevel%==0 ( set STATE=UNPREFIXED )

reg query "%BG_BASE%\1.%ITEM1%" >nul 2>&1
if %errorlevel%==0 ( set STATE=PREFIXED )

echo ^> Detected state: %STATE%
echo.

if %STATE%==UNKNOWN (
    echo ^> ERROR: Could not detect prefix state. Aborting.
    pause
    exit /B
)

:: Process items
for %%I in (1 2 3 4 5 6 7) do (
    set ORIGINAL_NAME=!ITEM%%I%!
    set PREFIXED_NAME=%%I.!ORIGINAL_NAME!

    if %STATE%==UNPREFIXED (
        echo ^> From "!ORIGINAL_NAME!" to "!PREFIXED_NAME!"

        :: BG = execute for 1 to 7
        echo ^>^> Background
        reg copy "%BG_BASE%\!ORIGINAL_NAME!" "%BG_BASE%\!PREFIXED_NAME!" /s /f
        reg delete "%BG_BASE%\!ORIGINAL_NAME!" /f
        
        :: DIR = skip 1, execute for 2 to 7
        echo ^>^> Directory
        if %%I==1 (
            echo Skipped.
        ) else (
            reg copy "%DIR_BASE%\!ORIGINAL_NAME!" "%DIR_BASE%\!PREFIXED_NAME!" /s /f
            reg delete "%DIR_BASE%\!ORIGINAL_NAME!" /f
        )

        echo.
    )

    if %STATE%==PREFIXED (
        echo ^> From "!PREFIXED_NAME!" to "!ORIGINAL_NAME!"

        :: BG = 1 to 7
        echo ^>^> Background
        reg copy "%BG_BASE%\!PREFIXED_NAME!" "%BG_BASE%\!ORIGINAL_NAME!" /s /f
        reg delete "%BG_BASE%\!PREFIXED_NAME!" /f

        :: DIR = skip 1, execute for 2 to 7
        echo ^>^> Directory
        if %%I==1 (
            echo Skipped.
        ) else (
            reg copy "%DIR_BASE%\!PREFIXED_NAME!" "%DIR_BASE%\!ORIGINAL_NAME!" /s /f
            reg delete "%DIR_BASE%\!PREFIXED_NAME!" /f
        )

        echo.
    )
)

echo ^> Prefix toggle complete.
pause
endlocal
