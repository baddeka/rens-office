@echo off
rem Rens Office on Windows: one click starts the newest version. Double-click this file, or the desktop shortcut
rem that "Add desktop shortcut.bat" makes for it.
chcp 65001 >nul
title Rens Office
cd /d "%~dp0"
rem uv and Claude Code install themselves here.
set "PATH=%USERPROFILE%\.local\bin;%PATH%"

where git >nul 2>nul
if errorlevel 1 (
  echo Git was not found, so the office starts as it is, without updating.
) else (
  echo Getting the newest version...
  git pull --ff-only
  if errorlevel 1 echo Could not update ^(no internet, or local changes^). Starting the version that is here.
)

rem uv brings its own Python, so nothing else needs installing; without it, the installed Python 3.11+ does.
where uv >nul 2>nul
if errorlevel 1 goto :system_python
if not exist ".venv\Scripts\python.exe" (
  echo First start: setting up, this takes a minute...
  uv venv --quiet --python 3.12 .venv
  if errorlevel 1 goto :failed
)
uv pip install --quiet --python .venv\Scripts\python.exe -e .
if errorlevel 1 goto :failed
goto :sign_in

:system_python
set "PY=python"
where py >nul 2>nul && set "PY=py"
if not exist ".venv\Scripts\python.exe" (
  echo First start: setting up, this takes a minute...
  %PY% -m venv .venv
  if errorlevel 1 goto :failed
)
".venv\Scripts\python.exe" -m pip install --quiet --disable-pip-version-check -e .
if errorlevel 1 goto :failed

:sign_in
rem The agents work through Claude Code, signed in with this person's own Claude account.
where claude >nul 2>nul
if errorlevel 1 (
  echo Claude Code was not found. Install it from https://code.claude.com, or run install.ps1, then start again.
  goto :start
)
claude auth status --json 2>nul | findstr /C:"\"loggedIn\": false" >nul
if errorlevel 1 goto :start
echo Sign in to Claude with your own account. A browser window opens for it.
call claude auth login
if errorlevel 1 echo Not signed in yet. The office starts anyway; run: claude auth login

:start

echo Starting the office. Close this window to stop it.
".venv\Scripts\python.exe" -m office.server --open %*
if errorlevel 1 pause
exit /b

:failed
echo.
echo The office could not be set up. Run install.ps1, or check that Python 3.11 or newer is installed.
pause
exit /b 1
