:: ============================================================
:: SMT v2.1 – System Maintenance Terminal (2026)
:: GitHub: https://github.com/pollhammer/smt
:: Author: Manuel Pollhammer
:: ============================================================

@echo off
setlocal EnableDelayedExpansion

for /f %%A in ('echo prompt $E^| cmd') do set "ESC=%%A"

title SMT v2.1 Dashboard
mode con cols=100 lines=38
chcp 65001>nul


:MENU

call :GetStats

cls

echo %ESC%[92m
echo ===================================================================================================
echo.
echo                                    ███████╗███╗   ███╗████████╗
echo                                    ██╔════╝████╗ ████║╚══██╔══╝
echo                                    ███████╗██╔████╔██║   ██║
echo                                    ╚════██║██║╚██╔╝██║   ██║
echo                                    ███████║██║ ╚═╝ ██║   ██║
echo                                    ╚══════╝╚═╝     ╚═╝   ╚═╝
echo.
echo                                 SYSTEM MAINTENANCE TERMINAL v2.1
echo                                       by Manuel Pollhammer
echo.             
echo ===================================================================================================
echo.

echo  CPU       : %CPU%%%
echo  RAM       : %RAMUSED% / %RAMTOTAL% GB
echo  SSD C:    : %DISKFREE% GB free
echo  Network   : %NETSTATUS%
echo  Uptime    : %UPTIME%
echo.
echo ---------------------------------------
echo.

echo  1  Clear Temporary Files
echo  2  Empty Recycle Bin
echo  3  Flush DNS Cache
echo  4  Run SFC Scan
echo  5  Run DISM Repair
echo  6  Check Disk Status
echo  7  View System Information
echo  8  Run Full Maintenance

echo.
echo  R  Refresh
echo  Q  Quit
echo.

choice /c 12345678RQ /n /m " Selection: "

set SEL=%errorlevel%

if %SEL%==1 goto TEMP
if %SEL%==2 goto RECYCLE
if %SEL%==3 goto DNS
if %SEL%==4 goto SFC
if %SEL%==5 goto DISM
if %SEL%==6 goto HW
if %SEL%==7 goto SYSINFO
if %SEL%==8 goto FULL
if %SEL%==9 goto MENU
if %SEL%==10 goto ENDE


:GetStats

for /f "tokens=1-6 delims=;" %%a in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stats.ps1"') do (

set CPU=%%a
set RAMUSED=%%b
set RAMTOTAL=%%c
set DISKFREE=%%d
set NETSTATUS=%%e
set UPTIME=%%f

)

exit /b



:TEMP

cls

echo Clearing TEMP files...
echo.

del /f /s /q "%TEMP%\*" >nul 2>&1

for /d %%D in ("%TEMP%\*") do (
rd /s /q "%%D" >nul 2>&1
)

echo.
echo Done.

pause

goto MENU




:RECYCLE

cls

echo.
echo Emptying Recycle Bin...
echo.

powershell -NoProfile -Command "try { Clear-RecycleBin -Force -ErrorAction Stop ; Write-Host '[OK] Recycle Bin emptied' } catch { Write-Host '[INFO] Recycle Bin is already empty' }"

echo.
pause

goto MENU


:DNS

cls

echo Flushing DNS Cache...
echo.

ipconfig /flushdns

echo.

pause

goto MENU




:SFC

cls

echo Starting SFC Scan...
echo.

sfc /scannow

pause

goto MENU




:DISM

cls

echo Starting DISM Repair...
echo.

DISM /Online /Cleanup-Image /RestoreHealth

pause

goto MENU




:HW

cls

powershell -NoProfile -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,Size -AutoSize"

pause
goto MENU




:SYSINFO

cls

systeminfo

pause

goto MENU




:FULL

cls

echo Starting Full Maintenance...
echo.

rem individual functions called inside full maintenance
echo [1/5] Clearing TEMP files...
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%D in ("%TEMP%\*") do ( rd /s /q "%%D" >nul 2>&1 )

echo [2/5] Emptying Recycle Bin...
powershell -NoProfile -Command "try { Clear-RecycleBin -Force -ErrorAction Stop } catch {}"

echo [3/5] Flushing DNS Cache...
ipconfig /flushdns >nul

echo.
echo [4/5] Starting SFC Scan...
sfc /scannow

echo.
echo [5/5] Starting DISM Repair...
DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo Full Maintenance completed successfully.
pause

goto MENU




:ENDE

cls

echo.
echo Thank you for using SMT v2.1
echo.

timeout /t 2 >nul

endlocal
exit
