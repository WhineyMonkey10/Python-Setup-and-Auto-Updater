@echo off
title Setting up Python environment...

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Please run this file as administrator.
    exit /b
)

:: python installation and setup

echo Installing Python...
curl https://www.python.org/ftp/python/3.10.4/python-3.10.4-amd64.exe -o python_installer.exe
if %errorlevel% neq 0 (
    echo Failed to download Python installer.
    exit /b
)

echo Running Python installer...
python_installer.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
if not exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" (
    echo Python installation failed.
    exit /b
)
echo Python is installed.

:: git installation and setup

echo Installing Git...
curl -L "https://github.com/git-for-windows/git/releases/download/v2.32.0.windows.2/Git-2.32.0.2-64-bit.exe" -o git_installer.exe
if %errorlevel% neq 0 (
    echo Failed to download Git installer.
    exit /b
)

echo Running Git installer...
git_installer.exe /VERYSILENT /NORESTART
if not exist "C:\Program Files\Git\git-cmd.exe" (
    echo Git installation failed.
    exit /b
)
echo Git is installed.

set gitExe="C:\Program Files\Git\bin\git.exe"

:: init. the git repository
set gitURL=http://github.com/USERNAME/REPOSITORY.git

echo Initializing git repository...
%gitExe% init
%gitExe% remote add origin %gitURL%
echo Git repository initialized.

:: fetch changes and set up tracking branch (even though the update file does this, it's still good to have it here)

echo Pulling code from GitHub...
%gitExe% fetch
if not exist ".git\refs\heads\main" (
    %gitExe% branch --track main origin/main
)
%gitExe% pull origin main
echo Code pulled.

:: pip installation and setup and dependency installation
echo Installing pip...
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
if %errorlevel% neq 0 (
    echo Failed to download get-pip.py.
    exit /b
)

"%LOCALAPPDATA%\Programs\Python\Python310\python.exe" get-pip.py
if not exist "%LOCALAPPDATA%\Programs\Python\Python310\Scripts\pip.exe" (
    echo Pip installation failed.
    exit /b
)
echo Pip is installed.
echo Installing dependencies from requirements.txt...
"%LOCALAPPDATA%\Programs\Python\Python310\Scripts\pip.exe" install -r requirements.txt
if %errorlevel% neq 0 (
    echo Failed to install dependencies.
    exit /b
)

echo Dependencies installed.

:: create desktop shortcut

echo Creating desktop shortcut...
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\main.lnk'); $Shortcut.TargetPath = 'cmd.exe'; $Shortcut.Arguments = '/c %USERPROFILE%\Desktop\FOLDER\update_and_run_main.cmd'; $Shortcut.Save()"
if %errorlevel% neq 0 (
    echo Failed to create desktop shortcut.
    exit /b
)
echo Desktop shortcut created.


:: clean up

echo Cleaning up...
del python_installer.exe
del get-pip.py
del git_installer.exe
echo Clean up complete.
echo Installation complete.
