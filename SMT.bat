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
echo  SSD C:    : %DISKFREE% GB frei
echo  Netzwerk  : %NETSTATUS%
echo  Uptime    : %UPTIME%
echo.
echo ---------------------------------------
echo.

echo  1  Temp Dateien löschen
echo  2  Papierkorb leeren
echo  3  DNS Cache leeren
echo  4  SFC Scan
echo  5  DISM Reparatur
echo  6  Disk Status
echo  7  Systeminformationen
echo  8  Vollwartung

echo.
echo  R  Aktualisieren
echo  Q  Beenden
echo.

choice /c 12345678RQ /n /m " Auswahl: "

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

echo Loesche TEMP Dateien...
echo.

del /f /s /q "%TEMP%\*" >nul 2>&1

for /d %%D in ("%TEMP%\*") do (
rd /s /q "%%D" >nul 2>&1
)

echo.
echo Fertig

pause

goto MENU




:RECYCLE

cls

echo.
echo Papierkorb wird geleert...
echo.

powershell -NoProfile -Command "try { Clear-RecycleBin -Force -ErrorAction Stop ; Write-Host '[OK] Papierkorb geleert' } catch { Write-Host '[INFO] Papierkorb bereits leer' }"

echo.
pause

goto MENU


:DNS

cls

echo DNS Cache wird geloescht...
echo.

ipconfig /flushdns

echo.

pause

goto MENU




:SFC

cls

echo Starte SFC...
echo.

sfc /scannow

pause

goto MENU




:DISM

cls

echo Starte DISM...
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

echo Starte Vollwartung...
echo.

call :TEMP
call :RECYCLE
call :DNS

echo.
echo Starte SFC...

sfc /scannow


echo.
echo Starte DISM...

DISM /Online /Cleanup-Image /RestoreHealth


pause

goto MENU




:ENDE

cls

echo.
echo Danke für die Nutzung von SMT v2.1
echo.

timeout /t 2 >nul

endlocal
exit