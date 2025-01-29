@echo off

REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1
IF %ERRORLEVEL% EQU 0 goto :Got_Admin

echo ===================================================================
echo This script needs to be executed as an administrator.
echo ===================================================================
echo.
pause
goto :EOF

:Got_Admin
echo.
echo ===================================================================
echo.
echo Run this command only when you're performing an
echo ISO upgrade from a ^< dev channel to dev channel!!!
echo.
echo ===================================================================
:choice
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto :RUN 
if /I "%c%" EQU "N" goto :EOF
goto :choice
echo.
:Run
bcdedit /set {current} flightsigning yes
echo.
:ASK_FOR_REBOOT
set "choice="
echo ===================================================================
echo.
echo A reboot is required to finish applying changes.
echo.
echo After rebooting just start setup.exe like you normally do.
echo.
echo Save your work before continuing!!!
echo.
echo ===================================================================
set /p choice="Would you like to reboot your PC? (y/N) "
echo.
if /I "%choice%"=="y" shutdown -r -t 5
goto :EOF