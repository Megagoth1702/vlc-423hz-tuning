@echo off
setlocal

set "SOURCE_FILE=%~dp0VLC-432Hz-tuning.lua"

if not defined APPDATA (
    echo ERROR: The APPDATA environment variable is not available.
    goto :failure
)

set "VLC_EXTENSIONS=%APPDATA%\vlc\lua\extensions"
set "DESTINATION=%VLC_EXTENSIONS%\VLC-432Hz-tuning.lua"

if not exist "%SOURCE_FILE%" (
    echo ERROR: VLC-432Hz-tuning.lua was not found beside this installer.
    goto :failure
)

if not exist "%VLC_EXTENSIONS%" (
    echo Creating "%VLC_EXTENSIONS%"...
    mkdir "%VLC_EXTENSIONS%"
    if errorlevel 1 goto :failure
)

copy /Y "%SOURCE_FILE%" "%DESTINATION%" >nul
if errorlevel 1 goto :failure

echo.
echo VLC 432 Hz Tuning was installed successfully.
echo Destination: "%DESTINATION%"
echo.
echo Restart VLC, then open View ^> 432 Hz Tuning.
goto :success

:failure
echo.
echo Installation failed. No numerology can repair a file-permission error.
if /I not "%~1"=="--no-pause" pause
exit /b 1

:success
if /I not "%~1"=="--no-pause" pause
exit /b 0
