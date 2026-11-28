@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0"
set "BIN_DIR=%ROOT_DIR%bin"
set "TARGET_NEW=%BIN_DIR%\bv_new.exe"
set "TARGET_EXE=%BIN_DIR%\bv.exe"
set "TARGET_BAK=%BIN_DIR%\bv.bak.exe"

if not defined BV_BUILD_VERSION (
    for /f "usebackq delims=" %%v in (`powershell -NoProfile -Command "$p='%ROOT_DIR%package.json'; if (Test-Path $p) { (Get-Content $p -Raw | ConvertFrom-Json).version }" 2^>nul`) do (
        if not defined BV_BUILD_VERSION set "BV_BUILD_VERSION=%%v"
    )
    if not defined BV_BUILD_VERSION set "BV_BUILD_VERSION=0.1.1"
)

echo ================================================================
echo   BlaiseVue CLI Native Build (Windows / CMD)
echo ================================================================

if not exist "%BIN_DIR%\bv.pas" (
    echo [ERROR] Source file not found: %BIN_DIR%\bv.pas
    exit /b 1
)

set "FPC_EXE="
where fpc >nul 2>&1
if %errorlevel%==0 (
    for /f "delims=" %%i in ('where fpc') do (
        if not defined FPC_EXE set "FPC_EXE=%%i"
    )
)
if not defined FPC_EXE if exist "C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe" set "FPC_EXE=C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe"
if not defined FPC_EXE if exist "C:\lazarus\fpc\3.2.0\bin\x86_64-win64\fpc.exe" set "FPC_EXE=C:\lazarus\fpc\3.2.0\bin\x86_64-win64\fpc.exe"
if not defined FPC_EXE if exist "D:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe" set "FPC_EXE=D:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe"
if not defined FPC_EXE if exist "C:\FPC\3.2.2\bin\i386-win32\fpc.exe" set "FPC_EXE=C:\FPC\3.2.2\bin\i386-win32\fpc.exe"

if not defined FPC_EXE (
    echo [ERROR] Free Pascal Compiler ^(fpc^) was not detected in PATH or standard Lazarus folders.
    echo         Install Lazarus IDE / FPC 3.2.2+: https://www.lazarus-ide.org/
    exit /b 1
)

echo   [+] FPC Compiler: %FPC_EXE%
echo   [+] Compiling bin\bv.pas -^> bin\bv_new.exe ...

pushd "%BIN_DIR%"
if exist bv_new.exe del /f /q bv_new.exe >nul 2>&1
"%FPC_EXE%" -MObjFPC -Sh -O2 -obv_new.exe bv.pas
set "BUILD_RC=%errorlevel%"
popd

if "%BUILD_RC%"=="0" if exist "%TARGET_NEW%" (
    if exist "%TARGET_EXE%" (
        copy /y "%TARGET_EXE%" "%TARGET_BAK%" >nul 2>&1
        echo   [BACKUP] Previous binary preserved at bin\bv.bak.exe
    )
    move /y "%TARGET_NEW%" "%TARGET_EXE%" >nul 2>&1
    echo.
    echo   [SUCCESS] BlaiseVue CLI built cleanly: bin\bv.exe
    "%TARGET_EXE%" --version
    echo.
    echo   Next step ^(if not already in PATH^):
    echo     Add "%BIN_DIR%" to your User PATH, then run: bv doctor
    echo ================================================================
    exit /b 0
)

if exist "%TARGET_NEW%" del /f /q "%TARGET_NEW%" >nul 2>&1
echo.
echo   [ERROR] Compilation failed. See Free Pascal output above.
if exist "%TARGET_EXE%" (
    echo   [SAFETY] Existing bin\bv.exe was NOT modified and remains functional.
)
echo ================================================================
exit /b 1
