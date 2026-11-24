@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Video enhancer (RIFE interpolation + optional Real-ESRGAN upscale)
REM  Usage:
REM    1) Drag a video onto this file, OR double-click and type a path.
REM    2) Command line:
REM       视频清晰化.bat <video> [fps] [scale] [doUpscale] [rifeModel] [esrganModel] [useHevc]
REM       e.g. 视频清晰化.bat "in.mp4" 120 2 1 rife-v4.6 realesr-animevideov3 0
REM  Defaults below can be edited.
REM ============================================================

REM ---- defaults (edit here) ----
set "TARGET_FPS=60"
set "SCALE=2"
set "DO_UPSCALE=1"
set "RIFE_MODEL=rife-v4.6"
set "ESRGAN_MODEL=realesr-animevideov3"
set "USE_HEVC=0"
REM ------------------------------

REM ---- command line overrides ----
set "VIDEO=%~1"
if not "%~2"=="" set "TARGET_FPS=%~2"
if not "%~3"=="" set "SCALE=%~3"
if not "%~4"=="" set "DO_UPSCALE=%~4"
if not "%~5"=="" set "RIFE_MODEL=%~5"
if not "%~6"=="" set "ESRGAN_MODEL=%~6"
if not "%~7"=="" set "USE_HEVC=%~7"

set "SCRIPT_DIR=%~dp0"
set "RIFE=%SCRIPT_DIR%rife-ncnn-vulkan\rife-ncnn-vulkan-20221029-windows\rife-ncnn-vulkan.exe"
set "ESRGAN=%SCRIPT_DIR%realesrgan-ncnn-vulkan.exe"

if "%VIDEO%"=="" (
    set /p "VIDEO=Drop a video file here - or type full path - "
)
if not exist "%VIDEO%" (
    echo [ERROR] File not found: "%VIDEO%"
    pause
    exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo [ERROR] ffmpeg not found in PATH. Install it first - see README.
    pause
    exit /b 1
)
if not exist "%RIFE%" (
    echo [ERROR] rife-ncnn-vulkan.exe not found at: "%RIFE%"
    pause
    exit /b 1
)
if "%DO_UPSCALE%"=="1" (
    if not exist "%ESRGAN%" (
        echo [ERROR] realesrgan-ncnn-vulkan.exe not found at: "%ESRGAN%"
        pause
        exit /b 1
    )
)

REM ---- encoder selection ----
if "%USE_HEVC%"=="1" (
    set "VCODEC=-c:v hevc_nvenc -preset p7 -cq 18 -b:v 0 -tag:v hvc1"
    set "OUT_EXT=_hevc"
) else (
    set "VCODEC=-c:v libx264 -preset medium -crf 18"
    set "OUT_EXT="
)

for %%F in ("%VIDEO%") do (
    set "DIR=%%~dpF"
    set "NAME=%%~nF"
)

set "WORK=%SCRIPT_DIR%_tmp"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%WORK%\frames" "%WORK%\interp" 2>nul
if "%DO_UPSCALE%"=="1" mkdir "%WORK%\upscaled" 2>nul

echo.
echo ============ Video enhancer ============
echo  Input      : "%VIDEO%"
echo  Target fps : %TARGET_FPS%   RIFE model: %RIFE_MODEL%
if "%DO_UPSCALE%"=="1" (
    echo  Upscale    : %SCALE%x       ESRGAN model: %ESRGAN_MODEL%
) else (
    echo  Upscale    : OFF
)
if "%USE_HEVC%"=="1" (echo  Encoder    : HEVC [hevc_nvenc]) else (echo  Encoder    : H.264 [libx264])
echo.

echo [1/7] Reading duration...
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "%VIDEO%" > "%WORK%\dur.txt" 2>nul
set /p DUR=<"%WORK%\dur.txt"
echo        duration = %DUR% s

echo [2/7] Calculating target frame count...
powershell -NoProfile -Command "[math]::Round(%DUR% * %TARGET_FPS%)" > "%WORK%\target.txt" 2>nul
set /p TARGET=<"%WORK%\target.txt"
echo        target frames = %TARGET%

echo [3/7] Extracting audio...
ffmpeg -y -i "%VIDEO%" -vn -acodec copy "%WORK%\audio.m4a" 2>nul

echo [4/7] Deduplicating frames - removing duplicates...
ffmpeg -y -i "%VIDEO%" -vf mpdecimate "%WORK%\frames\frame_%%08d.png" 2>nul
set "NFRAMES=0"
for %%f in ("%WORK%\frames\*.png") do set /a NFRAMES+=1
echo        unique frames = %NFRAMES%

echo [5/7] Interpolating %NFRAMES% -^> %TARGET% frames - GPU, please wait...
"%RIFE%" -i "%WORK%\frames" -o "%WORK%\interp" -m %RIFE_MODEL% -n %TARGET% -u -j 2:2:2

set "SRC=%WORK%\interp"
if "%DO_UPSCALE%"=="1" (
    echo [6/7] Upscaling by %SCALE%x - GPU, please wait...
    "%ESRGAN%" -i "%WORK%\interp" -o "%WORK%\upscaled" -n %ESRGAN_MODEL% -s %SCALE% -f png
    set "SRC=%WORK%\upscaled"
) else (
    echo [6/7] Upscale skipped.
)

echo [7/7] Merging with audio at %TARGET_FPS% fps...
if "%DO_UPSCALE%"=="1" (
    set "OUT=%DIR%%NAME%_%TARGET_FPS%fps_%SCALE%x%OUT_EXT%.mp4"
) else (
    set "OUT=%DIR%%NAME%_%TARGET_FPS%fps%OUT_EXT%.mp4"
)
if exist "%WORK%\audio.m4a" (
    ffmpeg -y -framerate %TARGET_FPS% -i "%SRC%\%%08d.png" -i "%WORK%\audio.m4a" -map 0:v:0 -map 1:a:0 -c:a copy %VCODEC% -pix_fmt yuv420p "%OUT%" 2>nul
) else (
    ffmpeg -y -framerate %TARGET_FPS% -i "%SRC%\%%08d.png" %VCODEC% -pix_fmt yuv420p "%OUT%" 2>nul
)

echo.
if exist "%OUT%" (
    echo ================= DONE =================
    echo  Output : "%OUT%"
    echo.
) else (
    echo [ERROR] Something went wrong - no output file produced.
    echo.
)

rmdir /s /q "%WORK%" 2>nul
pause
