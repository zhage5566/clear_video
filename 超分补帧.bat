@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Video upscale + frame interpolation (Real-ESRGAN + RIFE)
REM  One-click: removes duplicate frames, RIFE-interpolates to
REM  TARGET_FPS, then Real-ESRGAN upscales every frame by SCALE.
REM  Usage: drag a video file onto this .bat, OR double-click and type a path.
REM ============================================================

REM ---- settings you can change ----
set "TARGET_FPS=120"
set "SCALE=2"
set "RIFE_MODEL=rife-v4.6"
set "ESRGAN_MODEL=realesr-animevideov3"
REM  NOTE: SCALE must be 2/3/4 and match the model. realesr-animevideov3
REM        supports 2/3/4. For real-life video use ESRGAN_MODEL=realesrgan-x4plus
REM        with SCALE=4. For anime use realesr-animevideov3 (any scale).
REM  Video encoder: 0 = libx264 (software, works on any GPU)
REM                 1 = hevc_nvenc (NVIDIA only; avoids the H.264 8K@120fps
REM                     playback frame-drop problem on NVIDIA cards)
set "USE_HEVC=0"
REM ---------------------------------

REM ---- encoder selection (no need to edit) ----
if "%USE_HEVC%"=="1" (
    set "VCODEC=-c:v hevc_nvenc -preset p7 -cq 18 -b:v 0 -tag:v hvc1"
    set "OUT_EXT=_hevc"
) else (
    set "VCODEC=-c:v libx264 -preset medium -crf 18"
    set "OUT_EXT="
)

set "SCRIPT_DIR=%~dp0"
set "RIFE=%SCRIPT_DIR%rife-ncnn-vulkan\rife-ncnn-vulkan-20221029-windows\rife-ncnn-vulkan.exe"
set "ESRGAN=%SCRIPT_DIR%realesrgan-ncnn-vulkan.exe"

set "VIDEO=%~1"
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
    echo [ERROR] ffmpeg not found in PATH. Install it first - see README section 6 step 0.
    pause
    exit /b 1
)
if not exist "%RIFE%" (
    echo [ERROR] rife-ncnn-vulkan.exe not found at: "%RIFE%"
    pause
    exit /b 1
)
if not exist "%ESRGAN%" (
    echo [ERROR] realesrgan-ncnn-vulkan.exe not found at: "%ESRGAN%"
    pause
    exit /b 1
)

for %%F in ("%VIDEO%") do (
    set "DIR=%%~dpF"
    set "NAME=%%~nF"
)

set "WORK=%SCRIPT_DIR%_tmp_up"
if exist "%WORK%" rmdir /s /q "%WORK%"
mkdir "%WORK%\frames" "%WORK%\interp" "%WORK%\upscaled" 2>nul

echo.
echo ============ Upscale + RIFE interpolation ============
echo  Input      : "%VIDEO%"
echo  Target fps : %TARGET_FPS%   RIFE model: %RIFE_MODEL%
echo  Upscale    : %SCALE%x       ESRGAN model: %ESRGAN_MODEL%
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

echo [6/7] Upscaling %TARGET% frames by %SCALE%x - GPU, please wait...
"%ESRGAN%" -i "%WORK%\interp" -o "%WORK%\upscaled" -n %ESRGAN_MODEL% -s %SCALE% -f png

echo [7/7] Merging with audio at %TARGET_FPS% fps...
set "OUT=%DIR%%NAME%_%TARGET_FPS%fps_%SCALE%x%OUT_EXT%.mp4"
if exist "%WORK%\audio.m4a" (
    ffmpeg -y -framerate %TARGET_FPS% -i "%WORK%\upscaled\%%08d.png" -i "%WORK%\audio.m4a" -map 0:v:0 -map 1:a:0 -c:a copy %VCODEC% -pix_fmt yuv420p "%OUT%" 2>nul
) else (
    ffmpeg -y -framerate %TARGET_FPS% -i "%WORK%\upscaled\%%08d.png" %VCODEC% -pix_fmt yuv420p "%OUT%" 2>nul
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
