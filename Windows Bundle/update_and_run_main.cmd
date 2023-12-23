@echo off
cd /d "%USERPROFILE%\Desktop\FOLDER"

echo Checking for updates...
git fetch

:: check if the main branch exists locally and set tracking if not
if not exist ".git\refs\heads\main" (
    echo Setting up main branch...
    git branch --track main origin/main
)

:: get github updates
echo Updating from GitHub...
git pull origin main

setlocal EnableDelayedExpansion
set /a commitCount=0
for /f %%a in ('git rev-list --count HEAD') do set /a commitCount=%%a

echo Checking for changes in requirements.txt...
if !commitCount! gtr 1 (
    git diff --name-only HEAD@{1} HEAD | findstr "requirements.txt" >nul
    if not errorlevel 1 (
        echo Updating dependencies...
        "%LOCALAPPDATA%\Programs\Python\Python310\Scripts\pip.exe" install -r requirements.txt
    )
) else (
    echo Not enough commits for comparison.
)

echo Running main.py...
"%LOCALAPPDATA%\Programs\Python\Python310\python.exe" main.py
