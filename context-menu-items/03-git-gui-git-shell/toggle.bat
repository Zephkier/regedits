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

:: Path to registry keys
set GIT_GUI_BG_REG_KEY="HKEY_CLASSES_ROOT\Directory\Background\shell\git_gui"
set GIT_SHELL_BG_REG_KEY="HKEY_CLASSES_ROOT\Directory\Background\shell\git_shell"
set GIT_GUI_DIR_REG_KEY="HKEY_CLASSES_ROOT\Directory\shell\git_gui"
set GIT_SHELL_DIR_REG_KEY="HKEY_CLASSES_ROOT\Directory\shell\git_shell"

:: If registry key exists in that registry, then remove it (+ the others), else add it (+ the others)
reg query %GIT_GUI_BG_REG_KEY% >nul 2>&1

if %errorlevel%==0 (
    echo Removing "Open Git GUI here" and "Open Git Bash here" from context menu...
    reg delete %GIT_GUI_BG_REG_KEY% /f
    reg delete %GIT_SHELL_BG_REG_KEY% /f
    reg delete %GIT_GUI_DIR_REG_KEY% /f
    reg delete %GIT_SHELL_DIR_REG_KEY% /f
) else (
    echo Adding "Open Git GUI here" and "Open Git Bash here" from context menu...

    :: Background's Git GUI
    reg add %GIT_GUI_BG_REG_KEY% /ve /d "Open Git &GUI here" /f
    reg add %GIT_GUI_BG_REG_KEY% /v "Icon" /d "C:\Program Files\Git\cmd\git-gui.exe" /f
    reg add %GIT_GUI_BG_REG_KEY%\command /ve /d "\"C:\Program Files\Git\cmd\git-gui.exe\" \"--working-dir\" \"%%v.\"" /f

    :: Background's Git Bash
    reg add %GIT_SHELL_BG_REG_KEY% /ve /d "Open Git Ba&sh here" /f
    reg add %GIT_SHELL_BG_REG_KEY% /v "Icon" /d "C:\Program Files\Git\git-bash.exe" /f
    reg add %GIT_SHELL_BG_REG_KEY%\command /ve /d "\"C:\Program Files\Git\git-bash.exe\" \"--cd=%%v.\"" /f

    :: Directory's Git GUI
    reg add %GIT_GUI_DIR_REG_KEY% /ve /d "Open Git &GUI here" /f
    reg add %GIT_GUI_DIR_REG_KEY% /v "Icon" /d "C:\Program Files\Git\cmd\git-gui.exe" /f
    reg add %GIT_GUI_DIR_REG_KEY%\command /ve /d "\"C:\Program Files\Git\cmd\git-gui.exe\" \"--working-dir\" \"%%1\"" /f

    :: Directory's Git Bash
    reg add %GIT_SHELL_DIR_REG_KEY% /ve /d "Open Git Ba&sh here" /f
    reg add %GIT_SHELL_DIR_REG_KEY% /v "Icon" /d "C:\Program Files\Git\git-bash.exe" /f
    reg add %GIT_SHELL_DIR_REG_KEY%\command /ve /d "\"C:\Program Files\Git\git-bash.exe\" \"--cd=%%1\"" /f
)

pause
