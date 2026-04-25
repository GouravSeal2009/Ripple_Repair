@echo off
cd /d "%~dp0"
set "PROJECT=%CD%"
set "GODOT=%~dp0tools\Godot\Godot_v4.6.2-stable_win64.exe"
set "GODOT_FALLBACK=%LOCALAPPDATA%\Programs\Godot\Godot_v4.6.2-stable_win64.exe"
set "GODOT_DOWNLOAD=https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_win64.exe.zip"

if not exist "scripts" mkdir "scripts" >nul 2>nul
if not exist "scenes" mkdir "scenes" >nul 2>nul
if not exist "assets\background\objects" mkdir "assets\background\objects" >nul 2>nul

if exist "main.gd" if not exist "scripts\main.gd" move /y "main.gd" "scripts\main.gd" >nul
if exist "main.gd.uid" if not exist "scripts\main.gd.uid" move /y "main.gd.uid" "scripts\main.gd.uid" >nul
if exist "main.tscn" if not exist "scenes\main.tscn" move /y "main.tscn" "scenes\main.tscn" >nul

if exist "box.png" if not exist "assets\background\box.png" move /y "box.png" "assets\background\box.png" >nul
if exist "item1.png" if not exist "assets\background\item1.png" move /y "item1.png" "assets\background\item1.png" >nul
if exist "item2.png" if not exist "assets\background\item2.png" move /y "item2.png" "assets\background\item2.png" >nul
if exist "item3.png" if not exist "assets\background\item3.png" move /y "item3.png" "assets\background\item3.png" >nul
if exist "satellite.png" if not exist "assets\background\satellite.png" move /y "satellite.png" "assets\background\satellite.png" >nul
if exist "ship_2.png" if not exist "assets\background\ship_2.png" move /y "ship_2.png" "assets\background\ship_2.png" >nul
if exist "objects.zip" if not exist "assets\background\objects.zip" move /y "objects.zip" "assets\background\objects.zip" >nul

if exist "Trashbag.png" if not exist "assets\background\objects\Trashbag.png" move /y "Trashbag.png" "assets\background\objects\Trashbag.png" >nul
if exist "Debris_big.png" if not exist "assets\background\objects\Debris_big.png" move /y "Debris_big.png" "assets\background\objects\Debris_big.png" >nul
if exist "Debris_med.png" if not exist "assets\background\objects\Debris_med.png" move /y "Debris_med.png" "assets\background\objects\Debris_med.png" >nul
if exist "Debris_small.png" if not exist "assets\background\objects\Debris_small.png" move /y "Debris_small.png" "assets\background\objects\Debris_small.png" >nul
if exist "Rocks_big.png" if not exist "assets\background\objects\Rocks_big.png" move /y "Rocks_big.png" "assets\background\objects\Rocks_big.png" >nul
if exist "Rocks_med.png" if not exist "assets\background\objects\Rocks_med.png" move /y "Rocks_med.png" "assets\background\objects\Rocks_med.png" >nul
if exist "Rocks_small.png" if not exist "assets\background\objects\Rocks_small.png" move /y "Rocks_small.png" "assets\background\objects\Rocks_small.png" >nul

if not exist "%GODOT%" (
  set "GODOT=%GODOT_FALLBACK%"
)

if not exist "%GODOT%" (
  for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine*") do (
    if exist "%%~fD\Godot_v4.6.2-stable_win64.exe" set "GODOT=%%~fD\Godot_v4.6.2-stable_win64.exe"
  )
)

if not exist "%GODOT%" (
  where winget >nul 2>nul
  if %errorlevel%==0 (
    echo Godot was not found. Installing Godot 4.6.2 via winget...
    winget install --id GodotEngine.GodotEngine -e --accept-package-agreements --accept-source-agreements
  )
)

if not exist "%GODOT%" (
  if exist "%GODOT_FALLBACK%" set "GODOT=%GODOT_FALLBACK%"
)

if not exist "%GODOT%" (
  for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine*") do (
    if exist "%%~fD\Godot_v4.6.2-stable_win64.exe" set "GODOT=%%~fD\Godot_v4.6.2-stable_win64.exe"
  )
)

if not exist "%GODOT%" (
  echo Godot was not found at:
  echo %GODOT%
  echo.
  echo If winget could not install it automatically, download Godot 4.6.2 here:
  echo %GODOT_DOWNLOAD%
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
exit /b 0
