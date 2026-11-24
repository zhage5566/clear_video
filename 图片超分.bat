@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Image super-resolution (Real-ESRGAN upscale)
REM  Usage:
REM    1) Drag an image onto this file, OR double-click and type a path.
REM    2) Command line:
REM       image_upscale.bat <image> [scale] [model]
REM       e.g. image_upscale.bat "in.jpg" 2 realesr-animevideov3
REM  Defaults below can be edited.
REM ============================================================

REM ---- defaults (edit here) ----
set "SCALE=2"
set "MODEL=realesr-animevideov3"
REM ------------------------------

REM ---- command line overrides ----
set "IMAGE=%~1"
if not "%~2"=="" set "SCALE=%~2"
if not "%~3"=="" set "MODEL=%~3"

set "SCRIPT_DIR=%~dp0"
set "ESRGAN=%SCRIPT_DIR%realesrgan-ncnn-vulkan.exe"
set "MODELS=%SCRIPT_DIR%models"

if "%IMAGE%"=="" (
    set /p "IMAGE=Drop an image here - or type full path - "
)
if not exist "%IMAGE%" (
    echo [ERROR] File not found: "%IMAGE%"
    pause
    exit /b 1
)
if not exist "%ESRGAN%" (
    echo [ERROR] realesrgan-ncnn-vulkan.exe not found at: "%ESRGAN%"
    pause
    exit /b 1
)

for %%F in ("%IMAGE%") do (
    set "DIR=%%~dpF"
    set "NAME=%%~nF"
)

set "OUT=%DIR%%NAME%_%SCALE%x.png"

echo.
echo ============ Image super-resolution ============
echo  Input  : "%IMAGE%"
echo  Scale  : %SCALE%x       Model: %MODEL%
echo  Output : "%OUT%"
echo.

echo Upscaling - GPU, please wait...
"%ESRGAN%" -i "%IMAGE%" -o "%OUT%" -m "%MODELS%" -n %MODEL% -s %SCALE% -f png

echo.
if exist "%OUT%" (
    echo ================= DONE =================
    echo  Output : "%OUT%"
    echo.
) else (
    echo [ERROR] Something went wrong - no output file produced.
    echo.
)
pause
