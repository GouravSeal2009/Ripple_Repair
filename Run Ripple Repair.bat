@echo off
cd /d "%~dp0"
set "GODOT=%~dp0tools\Godot\Godot_v4.6.2-stable_win64.exe"
set "PROJECT=%CD%"

if not exist "%GODOT%" (
  set "GODOT=%LOCALAPPDATA%\Programs\Godot\Godot_v4.6.2-stable_win64.exe"
)

if not exist "%GODOT%" (
  echo Godot was not found at:
  echo %GODOT%
  echo.
  echo Reinstall Godot or ask Codex to install it again.
  pause
  exit /b 1
)

echo Starting Ripple Repair...
"%GODOT%" --fullscreen --rendering-driver opengl3 --rendering-method gl_compatibility --path "%PROJECT%"

if errorlevel 1 (
  echo.
  echo Godot could not start the game. Error code: %errorlevel%
  pause
)
