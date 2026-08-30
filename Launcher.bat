@echo off
setlocal EnableDelayedExpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "APP=%ROOT%\App"
set "EXE=%APP%\BedrockServerManager.exe"
set "INSTANCES=%ROOT%\Instances"
set "DEFAULT=%INSTANCES%\Default"

if not exist "%APP%\" (
    echo Error: App folder not found.
    pause
    exit /b 1
)

if not exist "%EXE%" (
    echo Error: BedrockServerManager.exe not found.
    pause
    exit /b 1
)

if not exist "%INSTANCES%\" mkdir "%INSTANCES%"
if not exist "%DEFAULT%\" mkdir "%DEFAULT%"

:MENU
cls
echo Bedrock Server Manager
echo ======================
echo.
echo Instances:
echo.

set "COUNT=0"

for /d %%D in ("%INSTANCES%\*") do (
    if /i not "%%~nxD"=="Default" (
        set /a COUNT+=1
        set "INSTANCE[!COUNT!]=%%~fD"
        echo   [!COUNT!] %%~nxD
    )
)

echo.
echo   [R] Refresh
echo   [Q] Exit
echo.
set "CHOICE="
set /p "CHOICE=Select [Default]: "

if not defined CHOICE set "CHOICE=Default"
if /i "%CHOICE%"=="Q" exit /b
if /i "%CHOICE%"=="R" goto MENU

if /i "%CHOICE%"=="Default" (
    set "SELECTED=%DEFAULT%"
    goto LAUNCH
)

if "%CHOICE%" geq "1" if "%CHOICE%" leq "%COUNT%" (
    call set "SELECTED=%%INSTANCE[%CHOICE%]%%"
    goto LAUNCH
)

echo.
echo Invalid selection.
timeout /t 2 /nobreak >nul
goto MENU

:LAUNCH
set "CONFIG=%SELECTED%\Config\config.ini"

if exist "%CONFIG%" (
    powershell -NoProfile -Command ^
      "$p='%CONFIG%'; $c=Get-Content -LiteralPath $p -Raw; $c=$c -replace '(?m)^(\s*RootPath=).*$', ('$1' + '%SELECTED%'); $c=$c -replace '(?m)^(\s*LocalBackupPath=).*$', '$1'; $c=$c -replace '(?m)^(\s*OffsiteBackupPath=).*$', '$1'; [IO.File]::WriteAllText($p,$c)"
)

start "" "%EXE%" -RootPath "%SELECTED%"
exit /b