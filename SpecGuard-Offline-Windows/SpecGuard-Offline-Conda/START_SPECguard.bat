@echo off
REM ==============================================================================
REM SpecGuard - Production Offline Launcher
REM Starts the local FastAPI web server on 0.0.0.0:8765
REM ==============================================================================

setlocal enabledelayedexpansion
title SpecGuard - Production Server

set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%"
set "ENV_DIR=%ROOT%environment\env"
set "ENV_TARBALL=%ROOT%environment\specguard-conda.tar.gz"
set "DATA_DIR=%ROOT%data"

if exist "%ROOT%app\app.py" (
    set "APP_DIR=%ROOT%app"
) else (
    set "APP_DIR=%ROOT%"
)

echo ==============================================================================
echo   SpecGuard - Engineering Document Quality ^& Compliance Inspection Platform
echo ==============================================================================
echo   Target Platform : Windows x64 (win-64)
echo   Network Mode    : 100%% Offline / Air-Gapped Intranet
echo   Deployment Path : %ROOT%
echo ==============================================================================
echo.

REM --- [1/4] Python Runtime Discovery ---
set "PYTHON_EXE="

if exist "%ENV_DIR%\python.exe" (
    set "PYTHON_EXE=%ENV_DIR%\python.exe"
    echo [1/4] Using local unpacked environment: !PYTHON_EXE!
) else if exist "%ENV_TARBALL%" (
    echo [1/4] Extracting packed Conda environment...
    if not exist "%ENV_DIR%" mkdir "%ENV_DIR%"
    tar -xzf "%ENV_TARBALL%" -C "%ENV_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to extract archive: %ENV_TARBALL%
        pause
        exit /b 1
    )
    set "PYTHON_EXE=%ENV_DIR%\python.exe"
) else (
    echo [1/4] Local packed environment not found. Checking system PATH for Python...
    for /f "delims=" %%i in ('where python 2^>nul') do (
        if not defined PYTHON_EXE set "PYTHON_EXE=%%i"
    )
)

if not defined PYTHON_EXE (
    echo [FATAL ERROR] No Python runtime found!
    pause
    exit /b 1
)

echo [OK] Using Python: %PYTHON_EXE%

REM --- [2/4] Runtime Isolation Environment Variables ---
echo [2/4] Setting runtime environment variables...
if exist "%ENV_DIR%\python.exe" (
    set "PYTHONHOME=%ENV_DIR%"
    set "PATH=%ENV_DIR%;%ENV_DIR%\Library\bin;%ENV_DIR%\Scripts;%PATH%"
)
set "PYTHONPATH=%ROOT%;%APP_DIR%;%ROOT%src;%APP_DIR%src"

set "HF_HUB_OFFLINE=1"
set "TRANSFORMERS_OFFLINE=1"
set "SPECGUARD_DATA_DIR=%DATA_DIR%"
set "SPECGUARD_APP_DIR=%APP_DIR%"
set "SPECGUARD_HOST=0.0.0.0"
set "SPECGUARD_PORT=8765"

if not exist "%DATA_DIR%" mkdir "%DATA_DIR%" 2>nul

REM --- [3/4] Verification Step ---
echo [3/4] Running pre-launch automated environment verification...
if exist "%ROOT%verify_environment.py" (
    "%PYTHON_EXE%" "%ROOT%verify_environment.py"
    if errorlevel 1 (
        echo.
        echo [FATAL] Environment verification failed!
        pause
        exit /b 1
    )
) else (
    echo [INFO] verify_environment.py not found in root, proceeding.
)

REM --- [4/4] Server Launch ---
echo [4/4] Starting SpecGuard Server...
echo.
echo ==============================================================================
echo   Local Web UI : http://localhost:8765
echo ==============================================================================
echo.

cd /d "%ROOT%"
"%PYTHON_EXE%" "%APP_DIR%\app.py" --host 0.0.0.0 --port 8765
if errorlevel 1 (
    echo.
    echo [ERROR] Server exited with an error code.
    pause
)