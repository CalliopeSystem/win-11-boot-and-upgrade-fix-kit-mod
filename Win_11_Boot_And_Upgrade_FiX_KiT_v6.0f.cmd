@ECHO off
::Options to set by the user
SET "Diskpart_and_Apply=1"
SET "EI_CFG_ADD=1"
SET "PID_TXT_ADD=0"
SET "Boot_WIM_Opt=1"
SET "Split_WIM_Opt=0"
SET "App_Res_Dll=1"
SET "Upgrade_Fail_Fix=0"
SET "Autorun=0"
SET "LOG_FILE=win11bufk.log"
SET "Add_Drivers=0"
SET "MOUNT_DIR=Mount"
SET "DRIVER_PATH=Drivers"
SET "Disable_BitLocker=0"
SET "Disable_MS_Account=0"
SET "OfflineInsiderEnroll=0"

::Options to set by dev
SET "Version=v6.0f"
SET "UFWS_version=v1.4"

REM change wording if needed..
TITLE Admin Check...
ECHO Checking for admin...

reg query HKU\S-1-5-19 1>nul 2>nul && goto :gotAdmin
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

:gotAdmin
PUSHD "%~dp0"
CD /D "%CD%"
@CLS

setlocal enabledelayedexpansion

:checkifrunning
set "lockfile=win11bufk.lock"

:: Check if lock file exists
if exist "%lockfile%" (
    echo.
    echo =============================================================
    echo ERROR: Script is already running!
    echo If you are sure the script is not running, delete %lockfile%!
    echo =============================================================
    echo.
    echo If you are sure the script is not already running or you are
    choice /c YN /n /m "running it in a different directory, delete %lockfile%? [Y/N]"
    if "!errorlevel!"=="1" (
        del /f /q "%lockfile%"
    ) else (
        exit /b 1
    )
)


:: Create the lock file
echo %date% %time% > "%lockfile%"
if exist %LOG_FILE% del /q %LOG_FILE%
if exist "%CD%\Work" rmdir /q /s "%CD%\Work"
if exist "%CD%\TEMP" rmdir /q /s "%CD%\TEMP"
TITLE Win 11 Boot ^& Upgrade FiX KiT %version% By Enthousiast ^@MDL modded by bloodrain ^@MDL...

:: Initialize variables
set "_tee="
set "_cdimage="
set "_7z="
set "_wimlib="

:: Detect CPU architecture
if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    echo 32-bit ^(x86^) architecture detected.
    set "_tee=Bin\tee.exe"
    set "_cdimage=Bin\oscdimg.exe"
    set "_7z=Bin\7z.exe"
    set "_wimlib=Bin\wimlib-imagex.exe"
) else if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo 64-bit ^(AMD64^) architecture detected.
    set "_tee=Bin\Bin64\tee.exe"
    set "_cdimage=Bin\Bin64\oscdimg.exe"
    set "_7z=Bin\Bin64\7z.exe"
    set "_wimlib=Bin\Bin64\wimlib-imagex.exe"
) else if "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    echo ARM64 architecture detected.
    set "_tee=Bin\BinArm64\tee.exe"
    set "_cdimage=Bin\BinArm64\oscdimg.exe"
    set "_7z=Bin\BinArm64\7z.exe"
    set "_wimlib=Bin\BinArm64\wimlib-imagex.exe"
) else (
    echo ERROR: Unknown architecture detected.
    exit /b 1
)



:Preparing

if exist "Work" rmdir /q /s "WORK"
if exist "TEMP" rmdir /q /s "TEMP"
call :checkmounted %MOUNT_DIR%

::md "WORK"
::md "TEMP"

SET select1=0
SET select2=0
SET select3=0
SET select4=0
SET select5=0
SET select6=0
SET select7=0
SET select8=0
SET select9=0
SET select10=0
SET select11=0
SET select12=0
SET select13=0
SET select14=0
SET select15=0
SET select16=0
IF /I "%App_Res_Dll%"=="1" SET select6=1
IF /I "%Diskpart_and_Apply%"=="1" SET select7=1
IF /I "%EI_CFG_ADD%"=="1" SET select8=1
IF /I "%Boot_WIM_Opt%"=="1" SET select9=1
IF /I "%Autorun%"=="1" SET select10=1
IF /I "%Disable_BitLocker%"=="1" SET select11=1
IF /I "%Add_Drivers%"=="1" SET select12=1
IF /I "%Disable_MS_Account%"=="1" SET select13=1
IF /I "%OfflineInsiderEnroll%"=="1" SET select14=1
IF /I "%PID_TXT_ADD%"=="1" SET select15=1
IF /I "%Split_WIM_Opt%"=="1" SET select16=1
:Loop
@CLS
::ECHO.
ECHO ====================================================================================
ECHO Win 11 Boot ^& Upgrade FiX KiT %version% By Enthousiast ^@MDL modded by bloodrain ^@MDL...
ECHO ====================================================================================
::ECHO.
if %select1%==0 if %select2%==0 if %select3%==0 if %select4%==0 if %select5%==0 SET select1=1
SET "option1={ }"
SET "option2={ }"
SET "option3={ }"
SET "option4={ }"
SET "option5={ }"
SET "option6={ }"
SET "option7={ }"
SET "option8={ }"
SET "option9={ }"
SET "option10={ }"
SET "option11={ }"
SET "option12={ }"
SET "option13={ }"
SET "option14={ }"
SET "option15={ }"
SET "option16={ }"
IF %select1%==1 SET "option1={*}"
IF %select2%==1 SET "option2={*}"
IF %select3%==1 SET "option3={*}"
IF %select4%==1 SET "option4={*}"
IF %select5%==1 SET "option5={*}"
IF %select6%==1 SET "option6={*}"
IF %select7%==1 SET "option7={*}"
IF %select8%==1 SET "option8={*}"
IF %select9%==1 SET "option9={*}"
IF %select10%==1 SET "option10={*}"
IF %select11%==1 SET "option11={*}"
IF %select12%==1 SET "option12={*}"
IF %select13%==1 SET "option13={*}"
IF %select14%==1 SET "option14={*}"
IF %select15%==1 SET "option15={*}"
IF %select16%==1 SET "option16={*}"
ECHO.
ECHO ====================================== Fixes =======================================
ECHO.
ECHO [ 1 ] %option1% AIO 1 : UFWS + setup.cfg ^(2022/2025^)
ECHO.
ECHO [ 2 ] %option2% AIO 2a: boot.wim Registry + winsetup.dll
ECHO [ 3 ] %option3% AIO 2b: Current OS Registry
ECHO.
ECHO [ 5 ] %option5% Use a Win 10 ISO setup files
ECHO.
ECHO ====================================== Extras ======================================
ECHO.
ECHO [ 6 ] %option6% Replace ISO appraiserres.dll
ECHO [ 7 ] %option7% Integrate Diskpart ^& Apply Image script
ECHO [ 8 ] %option8% Add the generic Ei.cfg file
ECHO [ 9 ] %option9% Optimize boot.wim
ECHO [ A ] %option10% Add 22621 Autorun.dll to 26100 ^(And higher^) Boot.wim ^(Only use this option when the ISO is already updated^!^)
ECHO [ B ] %option11% Disable automatic BitLocker encryption during Windows Setup
ECHO [ D ] %option12% Add drivers to boot.wim and install.wim ^(Will automatically convert esd and swm^)
ECHO [ M ] %option13% Disable requirement for Microsoft Account during setup
ECHO [ O ] %option14% Copy OfflineInsiderEnroll script to enable Windows Insider ISOs without Microsoft Account
ECHO [ P ] %option15% Add custom product key to PID.txt
ECHO [ S ] %option16% Split install.wim to 4GB for FAT32 USB sticks
ECHO.
ECHO ====================================================================================
SET CHOICE=0
choice /c 123456789ABDMOPS0 /n /m "Select desired option(s), then press 0 to start the process: "
set CHOICE=%errorlevel%
if %CHOICE%==1 (if %select1%==1 (set select1=0) else (set select1=1&set select5=0&set select2=0&set select3=0)&goto :Loop)
if %CHOICE%==2 (if %select2%==1 (set select2=0) else (set select2=1&set select5=0&set select1=0)&goto :Loop)
if %CHOICE%==3 (if %select3%==1 (set select3=0) else (set select3=1&set select5=0&set select1=0)&goto :Loop)
if %CHOICE%==4 (if %select4%==1 (set select4=0) else (set select4=1&set select5=0)&goto :Loop)
if %CHOICE%==5 (if %select5%==1 (set select5=0) else (set select5=1&set select1=0&set select2=0&set select3=0&set select4=0)&goto :Loop)
if %CHOICE%==6 (if %select6%==1 (set select6=0) else (set select6=1)&goto :Loop)
if %CHOICE%==7 (if %select7%==1 (set select7=0) else (set select7=1)&goto :Loop)
if %CHOICE%==8 (if %select8%==1 (set select8=0) else (set select8=1)&goto :Loop)
if %CHOICE%==9 (if %select9%==1 (set select9=0) else (set select9=1)&goto :Loop)
if %CHOICE%==10 (if %select10%==1 (set select10=0) else (set select10=1)&goto :Loop)
if %CHOICE%==11 (if %select11%==1 (set select11=0) else (set select11=1)&goto :Loop)
if %CHOICE%==12 (if %select12%==1 (set select12=0) else (set select12=1)&goto :Loop)
if %CHOICE%==13 (if %select13%==1 (set select13=0) else (set select13=1)&goto :Loop)
if %CHOICE%==14 (if %select14%==1 (set select14=0) else (set select14=1)&goto :Loop)
if %CHOICE%==15 (if %select15%==1 (set select15=0) else (set select15=1)&goto :Loop)
if %CHOICE%==16 (if %select16%==1 (set select16=0) else (set select16=1)&goto :Loop)
if %CHOICE%==17 goto :Begin
goto :Loop

:Begin
if %select3%==1 if %select1%==0 if %select2%==0 if %select4%==0 if %select5%==0 (
call :Mod_OS_Reg
GOTO :cleanup
)

SET "Block_SWM=0"
SET "FiX_UFWS=0"
SET "FiX_SetupCfg=0"
SET "FiX_OS_Reg=0"
SET "FiX_Boot_Reg=0"
SET "FiX_Boot_Dll=0"
SET "FiX_W10_ISO=0"
if %select1%==1 (SET "FiX_UFWS=1"&SET "FiX_SetupCfg=1"&SET "Block_SWM=1")
if %select2%==1 (SET "FiX_Boot_Reg=1"&SET "FiX_Boot_Dll=1"&SET "FiX_OS_Reg=1")
if %select3%==1 (SET "FiX_OS_Reg=1")
if %select5%==1 (SET "FiX_W10_ISO=1")
if %select6%==1 (SET "App_Res_Dll=1") else (SET "App_Res_Dll=0")
if %select7%==1 (SET "Diskpart_and_Apply=1") else (SET "Diskpart_and_Apply=0")
if %select8%==1 (SET "EI_CFG_ADD=1") else (SET "EI_CFG_ADD=0")
if %select9%==1 (SET "Boot_WIM_Opt=1") else (SET "Boot_WIM_Opt=0")
if %select10%==1 (SET "Autorun=1") else (SET "Autorun=0")
if %select11%==1 (SET "Disable_BitLocker=1") else (SET "Disable_BitLocker=0")
if %select12%==1 (SET "Add_Drivers=1") else (SET "Add_Drivers=0")
if %select13%==1 (SET "Disable_MS_Account=1") else (SET "Disable_MS_Account=0")
if %select14%==1 (SET "OfflineInsiderEnroll=1") else (SET "OfflineInsiderEnroll=0")
if %select15%==1 (SET "PID_TXT_ADD=1") else (SET "PID_TXT_ADD=0")
if %select16%==1 (SET "Split_WIM_Opt=1") else (SET "Split_WIM_Opt=0")

:: Echo selected options to log file
ECHO Selected options:>> %LOG_FILE%
if %select1%==1 (ECHO [ 1 ] %option1% AIO 1 : UFWS + setup.cfg ^(2022/2025^)>> %LOG_FILE%)
if %select2%==1 (ECHO [ 2 ] %option2% AIO 2a: boot.wim Registry + winsetup.dll>> %LOG_FILE%)
if %select3%==1 (ECHO [ 3 ] %option3% AIO 2b: Current OS Registry>> %LOG_FILE%)
if %select5%==1 (ECHO [ 5 ] %option5% Use a Win 10 ISO setup files>> %LOG_FILE%)
if %select6%==1 (ECHO [ 6 ] %option6% Replace ISO appraiserres.dll>> %LOG_FILE%)
if %select7%==1 (ECHO [ 7 ] %option7% Integrate Diskpart ^& Apply Image script>> %LOG_FILE%)
if %select8%==1 (ECHO [ 8 ] %option8% Add the generic Ei.cfg file>> %LOG_FILE%)
if %select9%==1 (ECHO [ 9 ] %option9% Optimize boot.wim>> %LOG_FILE%)
if %select10%==1 (ECHO [ A ] %option10% Add 22621 Autorun.dll to 26100 ^(And higher^) Boot.wim ^(Only use this option when the ISO is already updated^!^)>> %LOG_FILE%)
if %select11%==1 (ECHO [ B ] %option11% Disable automatic BitLocker encryption during Windows Setup>> %LOG_FILE%)
if %select12%==1 (ECHO [ D ] %option12% Add drivers to boot.wim and install.wim ^(Will automatically convert esd and swm^)>> %LOG_FILE%)
if %select13%==1 (ECHO [ M ] %option13% Disable requirement for Microsoft Account during setup>> %LOG_FILE%)
if %select14%==1 (ECHO [ O ] %option14% Copy OfflineInsiderEnroll script to enable Windows Insider ISOs without Microsoft Account>> %LOG_FILE%)
if %select15%==1 (ECHO [ P ] %option15% Add custom product key to PID.txt>> %LOG_FILE%)
if %select16%==1 (ECHO [ S ] %option16% Split install.wim for FAT32 USB sticks>> %LOG_FILE%)

if %FiX_W10_ISO%==1 if not exist "Source_ISO\W10\*.iso" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO No iso file detected in Source_ISO^\W10 dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
GOTO :cleanup
)

if not exist "Source_ISO\W11\*.iso" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO No iso file detected in Source_ISO^\W11 dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
GOTO :cleanup
)

for /f "delims=" %%i in ('dir /b Source_ISO\W11\*.iso') do %_7z% e -y -oTEMP "Source_ISO\W11\%%i" sources\setup.exe >nul
%_7z% l .\TEMP\setup.exe >.\TEMP\version.txt 2>&1
for /f "tokens=4 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version.txt') do set vermajor=%%i

%_7z% l .\Files\appraiserres.dll >.\TEMP\version2.txt 2>&1
for /f "tokens=4 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version2.txt') do set Appraiserres_Version=%%i

for /f "tokens=4,5 delims=. " %%i in ('findstr /i /b FileVersion .\TEMP\version.txt') do (set majorbuildnr=%%i&set deltabuildnr=%%j)

IF NOT DEFINED vermajor (
if exist "TEMP" rmdir /q /s "TEMP"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Detecting setup.exe version failed... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
pause
exit /b 1
)

SET "Winver="

IF %vermajor% GEQ 19041 SET "Winver=10"
IF %vermajor% GEQ 21996 SET "Winver=11"

IF NOT DEFINED Winver (
if exist "TEMP" rmdir /q /s "TEMP"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Unsupported iso version... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
pause
exit /b 1
)

IF %vermajor% GEQ 21996 SET "BUILD=22000"

IF NOT DEFINED BUILD (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Unsupported Win 10 build... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
pause
exit /b 1
)

if %FiX_W10_ISO%==1 GOTO :RESUME1

ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Extracting Win 11 Source ISO... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
%_7z% x -y -oWork\ Source_ISO\W11\ | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
Goto :RESUME2

:RESUME1
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Extracting Win 10 Source ISO... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
%_7z% x -y -oWork\ Source_ISO\W10\ -x!sources\install.* | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Extracting Win 11 install.wim/esd/swm to work dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
for /f %%i in ('dir /b Source_ISO\W11\*.iso') do %_7z% e -y -o"WORK\Sources" "Source_ISO\W11\%%i" sources\install.* >nul

:RESUME2
:: Initialize variables
set WIMFILE=
set BOOTFILE=

:: Check for install files
if exist "Work\sources\install.wim" (
    set WIMFILE=install.wim
) else if exist "Work\sources\install.esd" (
    set WIMFILE=install.esd
) else if exist "Work\sources\install.swm" (
    set WIMFILE=install.swm
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: install.wim, install.esd, or install.swm not found in Work\sources! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Check for boot files
if exist "Work\sources\boot.wim" (
    set BOOTFILE=boot.wim
) else if exist "Work\sources\boot.esd" (
    set BOOTFILE=boot.esd
) else if exist "Work\sources\boot.swm" (
    set BOOTFILE=boot.swm
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: boot.wim, boot.esd, or boot.swm not found in Work\sources! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Log success
echo Found WIMFILE: %WIMFILE% | "%_tee%" -a "%LOG_FILE%"
echo Found BOOTFILE: %BOOTFILE% | "%_tee%" -a "%LOG_FILE%"


:: if exist "Work\sources\install.swm" if %Block_SWM%==1 (
:: ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
:: ECHO Install.swm file detected, UFWS FiX is disabled... | "%_tee%" -a "%LOG_FILE%"
:: ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
:: ECHO. | "%_tee%" -a "%LOG_FILE%"
:: SET "FiX_UFWS=0"&SET "FiX_SetupCfg=0"

if exist "Work\sources\install.swm" (
    if %Block_SWM%==1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
	    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO Work\Sources\%WIMFILE% is a .swm file, combining into a wim file. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
	    call :convertswm Work\sources\%WIMFILE% Work\sources\install.wim
	    if errorlevel 0 (
		    set WIMFILE=install.wim
		    set "Split_WIM_Opt=1"
	    ) else (
		    ECHO. | "%_tee%" -a "%LOG_FILE%"
			ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
            ECHO Error combining SWM files! | "%_tee%" -a "%LOG_FILE%"
            ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
			ECHO. | "%_tee%" -a "%LOG_FILE%"
	        exit /b 1
	    )
    )
)
set "Split_Boot_WIM_Opt=0"
if exist "Work\sources\boot.swm" (
    if %Block_SWM%==1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO Work\Sources\%BOOTFILE% is a .swm file, combining into a wim file. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
	    set "sourceSwm=Work\sources\%BOOTFILE%"
	    call :convertswm Work\sources\%BOOTFILE% Work\sources\boot.wim
	    if errorlevel 0 (
		    set WIMFILE=boot.wim
		    set "Split_Boot_WIM_Opt=1"
	    ) else (
		    ECHO. | "%_tee%" -a "%LOG_FILE%"
	        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
            ECHO Error combining SWM files! | "%_tee%" -a "%LOG_FILE%"
            ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
			ECHO. | "%_tee%" -a "%LOG_FILE%"
	        exit /b 1
	    )
    )
)

if %select2%==0 if %select4%==0 if %select5%==0 (
  SET "FiX_Boot_Reg=1"&SET "FiX_Boot_Dll=1"&SET "FiX_OS_Reg=1"
  ECHO Revert to AIO 2 | "%_tee%" -a "%LOG_FILE%"
  )
)

REM detect wim arch
:detectwimarch
for /f "tokens=2 delims=: " %%# in ('dism.exe /english /get-wiminfo /wimfile:"Work\sources\%WIMFILE%" /index:1 ^| find /i "Architecture"') do set warch=%%#

for /f "tokens=3 delims=: " %%m in ('dism.exe /english /Get-WimInfo /wimfile:"Work\sources\%WIMFILE%" /Index:1 ^| findstr /i Build') do set b2=%%m

:Win11Lang
REM detect extracted win11 iso language
set "IsoLang=ar-SA,bg-BG,cs-CZ,da-DK,de-DE,el-GR,en-GB,en-US,es-ES,es-MX,et-EE,fi-FI,fr-CA,fr-FR,he-IL,hr-HR,hu-HU,it-IT,ja-JP,ko-KR,lt-LT,lv-LV,nb-NO,nl-NL,pl-PL,pt-BR,pt-PT,ro-RO,ru-RU,sk-SK,sl-SI,sr-RS,sv-SE,th-TH,tr-TR,uk-UA,zh-CN,zh-TW"
for %%i in (%IsoLang%) do if exist "Work\sources\%%i\*.mui" set %%i=1

REM set ISO label lang
for %%i in (%IsoLang%) do if defined %%i (
SET "LabelLang=%%i"
)

:eicfg
IF /I "%EI_CFG_ADD%" NEQ "1" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO You have chosen to NOT copy the generic Ei.cfg file. | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ^(If exists, the original file will remain on the ISO^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
) ELSE (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying the generic Ei.cfg to the work dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ^(If exists, the original file will be renamed to Ei.cfg.Ori^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
IF EXIST "WORK\Sources\Ei.cfg" ren "WORK\Sources\Ei.cfg" "Ei.cfg.Ori"
COPY /Y "Files\Ei.CFG" "WORK\Sources\" | "%_tee%" -a "%LOG_FILE%"
)

:pidtxt
IF /I "%PID_TXT_ADD%" NEQ "1" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO You have chosen to NOT to enter a custom product key. | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ^(If exists, the original PID.txt will remain on the ISO^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
goto donepid
) ELSE (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Enter the product key below | "%_tee%" -a "%LOG_FILE%"
ECHO ^(If exists, the original file will be renamed to PID.txt.Ori^) | "%_tee%" -a "%LOG_FILE%"
ECHO Please ensure it is 25 characters long, | "%_tee%" -a "%LOG_FILE%"
ECHO divided into 5 groups of 5 characters separated by hyphens. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
)
IF EXIST "WORK\Sources\PID.txt" ren "WORK\Sources\PID.txt" "PID.txt.Ori"
:setpid
set invalidpid=0
:invalidpid
if "%invalidpid%"=="0" goto inputpid
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO The product key format is invalid. | "%_tee%" -a "%LOG_FILE%"
ECHO Please ensure it is 25 alphanumeric characters long, | "%_tee%" -a "%LOG_FILE%"
ECHO divided into 5 groups of 5 characters separated by hyphens. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"

:inputpid
set /p "PID=Enter product key (XXXXX-XXXXX-XXXXX-XXXXX-XXXXX): "

:: Validate the product key format

powershell if ('%PID%' -match '^[2-9BCDFGHJKLMNPQRTVWXY]{5}-[2-9BCDFGHJKLMNPQRTVWXY]{5}-[2-9BCDFGHJKLMNPQRTVWXY]{5}-[2-9BCDFGHJKLMNPQRTVWXY]{5}-[2-9BCDFGHJKLMNPQRTVWXY]{5}$') { Write-Output '0' } else { Write-Output '1' }|findstr /C:0
if %errorlevel% neq 0 (
    set "invalidpid=1"
    goto invalidpid
)

ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Creating PID.txt | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
echo [PID]> "%CD%\Work\sources\PID.txt"
echo Value=%PID%>> "%CD%\Work\sources\PID.txt"
:donepid
if %FiX_W10_ISO%==1 GOTO :ISO_FiX_W10

:FiX_UFWS
IF /I "%FiX_UFWS%" NEQ "1" GOTO :FiX_SetupCfg
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Applying UFWS %UFWS_version% to %WIMFILE% | "%_tee%" -a "%LOG_FILE%"
ECHO ^(Circumvent CPU-Disksize-RAM-TPM-Secureboot checks^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
for /f "tokens=3 delims=: " %%i in ('%_wimlib% info Work\sources\%WIMFILE% ^| findstr /c:"Image Count"') do set images=%%i
for /L %%i in (1,1,%images%) do (
  %_wimlib% info "Work\sources\%WIMFILE%" %%i --image-property WINDOWS/INSTALLATIONTYPE=Server >nul
)

:FiX_SetupCfg
IF /I "%FiX_SetupCfg%" NEQ "1" GOTO :FiX_OS_Reg
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Replacing setup.cfg for ISO dir ^& boot.wim | "%_tee%" -a "%LOG_FILE%"
ECHO ^(The original file will be renamed to setup.cfg.bak^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
SET src_cfg=setup2022.cfg
IF %vermajor% GEQ 25900 set src_cfg=setup2025.cfg
ren "WORK\sources\inf\setup.cfg" "setup.cfg.bak" 2>nul
copy /Y "Files\%src_cfg%" "WORK\Sources\inf\setup.cfg" | "%_tee%" -a "%LOG_FILE%"
%_wimlib% update "WORK\sources\boot.wim" 2 --command="add 'Files\%src_cfg%' '\sources\inf\setup.cfg'" | "%_tee%" -a "%LOG_FILE%"

:FiX_OS_Reg
IF /I "%FiX_OS_Reg%" NEQ "1" GOTO :FiX_Boot_Reg | "%_tee%" -a "%LOG_FILE%"
call :Mod_OS_Reg
IF NOT EXIST "WORK\24H2_Online_Upgrade_Enabler_Script.cmd" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying 24H2+ 24H2_Online_Upgrade_Enabler_Script.cmd to ISO dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
COPY /Y "Files\24H2_Online_Upgrade_Enabler_Script.cmd" "WORK\" | "%_tee%" -a "%LOG_FILE%"
)

:FiX_Boot_Reg
IF /I "%FiX_Boot_Reg%" NEQ "1" GOTO :FiX_Boot_Dll
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Modding Boot.wim registry | "%_tee%" -a "%LOG_FILE%"
ECHO ^(Bypass RAM-TPM-Secureboot checks for legacy setup^) | "%_tee%" -a "%LOG_FILE%"
ECHO ^(Bypass CPU-Disksize-RAM-TPM-Secureboot checks for new setup^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
::if exist "TEMP" rmdir /q /s "TEMP"

%_wimlib% extract "WORK\sources\boot.wim" 2 \Windows\System32\config\SYSTEM --no-acls --no-attributes --dest-dir="TEMP" | "%_tee%" -a "%LOG_FILE%"
%_wimlib% extract "WORK\sources\boot.wim" 2 \Windows\System32\config\SOFTWARE --no-acls --no-attributes --dest-dir="TEMP" | "%_tee%" -a "%LOG_FILE%"

ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO - Adding LabConfig registry: | "%_tee%" -a "%LOG_FILE%"
Reg.exe load HKLM\MDL_Test "TEMP\SYSTEM" | "%_tee%" -a "%LOG_FILE%"
Reg.exe add "HKLM\MDL_Test\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d "1" /f | "%_tee%" -a "%LOG_FILE%"
Reg.exe add "HKLM\MDL_Test\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d "1" /f | "%_tee%" -a "%LOG_FILE%"
Reg.exe add "HKLM\MDL_Test\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d "1" /f | "%_tee%" -a "%LOG_FILE%"
Reg.exe unload HKLM\MDL_Test | "%_tee%" -a "%LOG_FILE%"

ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO - Adding HwReqChkVars registry: | "%_tee%" -a "%LOG_FILE%"
SET "ACF=HKLM\MDL_Test\Microsoft\Windows NT\CurrentVersion\AppCompatFlags" | "%_tee%" -a "%LOG_FILE%"
Reg.exe load HKLM\MDL_Test "TEMP\SOFTWARE" | "%_tee%" -a "%LOG_FILE%"
Reg.exe delete "%ACF%\CompatMarkers" /f 2>nul
Reg.exe delete "%ACF%\Shared" /f 2>nul
Reg.exe delete "%ACF%\TargetVersionUpgradeExperienceIndicators" /f 2>nul
Reg.exe add "%ACF%\HwReqChk" /f /v "HwReqChkVars" /t REG_MULTI_SZ /s "," /d "SQ_SSE2ProcessorSupport=TRUE,SQ_SSE4_2ProcessorSupport=TRUE,SQ_NXProcessorSupport=TRUE,SQ_CompareExchange128=TRUE,SQ_LahfSahfSupport=TRUE,SQ_PrefetchWSupport=TRUE,SQ_PopCntInstructionSupport=TRUE,SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=9999,SQ_SystemDiskSizeMB=99999,SQ_CpuCoreCount=9,SQ_CpuModel=99,SQ_CpuFamily=99,SQ_CpuMhz=9999," | "%_tee%" -a "%LOG_FILE%"
Reg.exe unload HKLM\MDL_Test | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"

%_wimlib% update "WORK\sources\boot.wim" 2 --command="add 'TEMP\SYSTEM' '\Windows\System32\config\SYSTEM'" | "%_tee%" -a "%LOG_FILE%"
%_wimlib% update "WORK\sources\boot.wim" 2 --command="add 'TEMP\SOFTWARE' '\Windows\System32\config\SOFTWARE'" | "%_tee%" -a "%LOG_FILE%"

:FiX_Boot_Dll
IF /I "%FiX_Boot_Dll%" NEQ "1" GOTO :FiX_App_Res
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Modding Boot.wim winsetup.dll | "%_tee%" -a "%LOG_FILE%"
ECHO ^(Suppress HWRequirements checks for legacy setup^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
::if exist "TEMP" rmdir /q /s "TEMP"

%_wimlib% extract "WORK\sources\boot.wim" 2 \sources\winsetup.dll --no-acls --no-attributes --dest-dir="TEMP" | "%_tee%" -a "%LOG_FILE%"

set "d1=$winsetup = 'TEMP\winsetup.dll'; $b = [io.file]::ReadAllBytes($winsetup); $h = [BitConverter]::ToString($b) -replace '-'"
set "d2=$s = [BitConverter]::ToString([Text.Encoding]::Unicode.GetBytes('Module_Init_HWRequirements')) -replace '-'"
set "d3=$i = ($h.IndexOf($s)/2); $r = [Text.Encoding]::Unicode.GetBytes('Module_Init_GatherDiskInfo'); $l = $r.Length"
set "d4=if ($i -gt 1) {for ($k=0;$k -lt $l;$k++) {$b[$i+$k] = $r[$k]}; [io.file]::WriteAllBytes($winsetup,$b)}; [GC]::Collect()"
powershell -nop -c "%d1%; %d2%; %d3%; %d4%" | "%_tee%" -a "%LOG_FILE%"

%_wimlib% update "WORK\sources\boot.wim" 2 --command="add 'TEMP\winsetup.dll' '\sources\winsetup.dll'" | "%_tee%" -a "%LOG_FILE%"

:FiX_App_Res
IF /I "%App_Res_Dll%" NEQ "1" GOTO :ISO_FiX_W11
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Replacing Win11 appraiserres.dll with Win10 %Appraiserres_Version% | "%_tee%" -a "%LOG_FILE%"
ECHO ^(The original file will be renamed to appraiserres.dll.bak^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ren "WORK\sources\appraiserres.dll" "appraiserres.dll.bak" 2>nul
copy /Y "Files\appraiserres.dll" "WORK\Sources" | "%_tee%" -a "%LOG_FILE%"

:ISO_FiX_W11
IF /I "%Diskpart_and_Apply%" NEQ "1" GOTO :RESUME3
call :getfileext Work\Sources\%BOOTFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .esd file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%BOOTFILE% Work\sources\boot.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set BOOTFILE=boot.wim
    set set "Split_Boot_WIM_Opt=1"
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%BOOTFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Adding Murphy78 Diskpart and Apply Image Script 1.3.1 To Boot.wim... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
%_wimlib% update Work\sources\boot.wim 2 --command="add 'Files\murphy78-DiskPart-Apply-v1.3.1\%warch%\' '\'" | "%_tee%" -a "%LOG_FILE%"
:RESUME3
IF /I "%Upgrade_Fail_Fix%" NEQ "1" GOTO :RESUME4
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying Upgrade_Fail_Fix.cmd to ISO dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
COPY /Y "Files\Upgrade_Fail_Fix.cmd" "WORK\" | "%_tee%" -a "%LOG_FILE%"
:RESUME4
IF /I "%Boot_WIM_Opt%" NEQ "1" GOTO :SKIP_2
call :getfileext Work\Sources\%BOOTFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .esd file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%BOOTFILE% Work\sources\boot.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set BOOTFILE=boot.wim
    set set "Split_Boot_WIM_Opt=1"
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%BOOTFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Optimizing boot.wim... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
%_wimlib% optimize "WORK\Sources\boot.wim" --recompress | "%_tee%" -a "%LOG_FILE%"
:SKIP_2

IF /I "%Autorun%" NEQ "1" GOTO :RESUME5
call :getfileext Work\Sources\%BOOTFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .esd file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%BOOTFILE% Work\sources\boot.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set BOOTFILE=boot.wim
    set set "Split_Boot_WIM_Opt=1"
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%BOOTFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Adding 22621 Autorun.dll to 26100 ^(or later^) boot.wim... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
IF /I "%vermajor%" LSS "26100" (
  echo.
  echo ============================================================= | "%_tee%" -a "%LOG_FILE%"
  echo The ISO build is not 26100 or later, skipping... | "%_tee%" -a "%LOG_FILE%"
  echo ============================================================= | "%_tee%" -a "%LOG_FILE%"
  echo. | "%_tee%" -a "%LOG_FILE%"
) else (
%_wimlib% update Work\Sources\boot.wim 2 --command="add 'Files\autorun_22621.dll' '\sources\autorun.dll'" | "%_tee%" -a "%LOG_FILE%"
)
:RESUME5

IF NOT EXIST "WORK\24H2_Online_Upgrade_Enabler_Script.cmd" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying 24H2+ 24H2_Online_Upgrade_Enabler_Script.cmd to ISO dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
COPY /Y "Files\24H2_Online_Upgrade_Enabler_Script.cmd" "WORK\" | "%_tee%" -a "%LOG_FILE%"
)
if "%OfflineInsiderEnroll%"=="1" call :offlineinsiderenroll
if "%Disable_BitLocker%"=="1" call :disablebitlocker
if "%Disable_MS_Account%"=="1" call :disablemsaccount
if "%Add_Drivers%"=="1" call :adddrivers
if "%Split_WIM_Opt%"=="0" (
    if "!Conv_ESD_Opt!"=="1" (
        call :wimtoesd Work\sources\%WIMFILE% Work\sources\install.esd
    )
) else if "!Split_WIM_Opt!"=="1" (
    call :splitwim
)

if "%Split_Boot_WIM_Opt%"=="0" (
    if "!Conv_BESD_Opt!"=="1" (
        call :wimtoesd Work\sources\%BOOTFILE% Work\sources\install.esd
    )
) else if "!Split_Boot_WIM_Opt!"=="1" (
    call :splitbootwim
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Creating %WARCH% ISO... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
xcopy /s /i /Q "$OEM$" "WORK\Sources" >NUL 2>&1
for /f %%# in ('powershell "get-date -format _yyyy_MM_dd"') do set "isodate=%%#"
if not defined isodate set "isodate=_0000_00_00"
for /f "delims=" %%i in ('dir /b Source_ISO\W11\*.iso') do set "isoname=%%i"
set "isoname=%isoname:~0,-4%_FIXED%isodate%.iso"
ECHO.
set LABEL=Win_%Winver%_%vermajor%_%warch%_%LabelLang%
call :setlabel 11
%_cdimage% -bootdata:2#p0,e,b"Work\boot\etfsboot.com"#pEF,e,b"Work\efi\Microsoft\boot\efisys.bin" -o -m -u2 -udfver102 -l!LABEL! "Work" "%isoname%" | "%_tee%" -a "%LOG_FILE%"
GOTO :cleanup

:ISO_FiX_W10
IF /I "%Boot_WIM_Opt%" NEQ "1" GOTO :SKIP_3
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Optimizing boot.wim... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
%_wimlib% optimize "WORK\Sources\boot.wim" --recompress | "%_tee%" -a "%LOG_FILE%"
:SKIP_3
IF NOT EXIST "WORK\24H2_Online_Upgrade_Enabler_Script.cmd" (
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying 24H2+ 24H2_Online_Upgrade_Enabler_Script.cmd to ISO dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
COPY /Y "Files\24H2_Online_Upgrade_Enabler_Script.cmd" "WORK\" | "%_tee%" -a "%LOG_FILE%"
)
if "%OfflineInsiderEnroll%"=="1" call :offlineinsiderenroll
if "%Disable_BitLocker%"=="1" call :disablebitlocker
if "%Disable_MS_Account%"=="1" call :disablemsaccount
if "%Add_Drivers%"=="1" call :adddrivers
if "%Split_WIM_Opt%"=="0" (
    if "!Conv_ESD_Opt!"=="1" (
        call :wimtoesd Work\sources\%WIMFILE% Work\sources\install.esd
    )
) else if "!Split_WIM_Opt!"=="1" (
    call :splitwim
)

if "%Split_Boot_WIM_Opt%"=="0" (
    if "!Conv_BESD_Opt!"=="1" (
        call :wimtoesd Work\sources\%BOOTFILE% Work\sources\install.esd
    )
) else if "!Split_Boot_WIM_Opt!"=="1" (
    call :splitbootwim
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Creating %WARCH% ISO... | "%_tee%" -a "%LOG_FILE%"
ECHO ========================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
xcopy /s /i /Q "OEM" "WORK\Sources" >NUL 2>&1
for /f %%# in ('powershell "get-date -format _yyyy_MM_dd"') do set "isodate=%%#"
if not defined isodate set "isodate=_0000_00_00"
ECHO. | "%_tee%" -a "%LOG_FILE%"
set LABEL=Win_%Winver%_%vermajor%_%warch%_%LabelLang%
call :setlabel 10
%_cdimage% -bootdata:2#p0,e,b"Work\boot\etfsboot.com"#pEF,e,b"Work\efi\Microsoft\boot\efisys.bin" -o -m -u2 -udfver102 -l!LABEL! "Work" Win_10_ISO_With_%majorbuildnr%.%b2%_%wARCH%_%LabelLang%_%WIMFILE%_FiXED%isodate%.iso | "%_tee%" -a "%LOG_FILE%"

:cleanup
if exist "TEMP" rmdir /q /s "TEMP"
if exist "Work" rmdir /q /s "WORK"
if exist "%lockfile%" del "%lockfile%"
ECHO.
ECHO Press 9 or q to exit.
choice /c 9Q /n
if errorlevel 1 (exit) else (rem.)
endlocal
pause
exit /b

:Mod_OS_Reg
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Adding HwReqChkVars registry for Current OS | "%_tee%" -a "%LOG_FILE%"
ECHO ^(Bypass CPU-Disksize-RAM-TPM-Secureboot checks for upgrade^) | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
SET "ACF=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags"
Reg.exe delete "%ACF%\CompatMarkers" /f 2>nul | "%_tee%" -a "%LOG_FILE%"
Reg.exe delete "%ACF%\Shared" /f 2>nul | "%_tee%" -a "%LOG_FILE%"
Reg.exe delete "%ACF%\TargetVersionUpgradeExperienceIndicators" /f 2>nul | "%_tee%" -a "%LOG_FILE%"
Reg.exe add "%ACF%\HwReqChk" /f /v "HwReqChkVars" /t REG_MULTI_SZ /s "," /d "SQ_SSE2ProcessorSupport=TRUE,SQ_SSE4_2ProcessorSupport=TRUE,SQ_NXProcessorSupport=TRUE,SQ_CompareExchange128=TRUE,SQ_LahfSahfSupport=TRUE,SQ_PrefetchWSupport=TRUE,SQ_PopCntInstructionSupport=TRUE,SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=9999,SQ_SystemDiskSizeMB=99999,SQ_CpuCoreCount=9,SQ_CpuModel=99,SQ_CpuFamily=99,SQ_CpuMhz=9999,"
Reg.exe add "HKLM\SYSTEM\Setup\MoSetup" /f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1"
exit /b

:setlabel
:: Set the directory where the ISO files are located
set "folder=%CD%\Source_ISO\W%1"

:: Initialize a flag to check if the first ISO file has been found
set found=0

:: Check if the folder exists
if not exist "%folder%" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Folder "%folder%" does not exist. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Loop through the ISO files in the folder
for %%f in ("%folder%\*.iso") do (
    if !found! equ 0 (
        :: Run 7z to list the archive contents and search for the Comment field
        for /f "tokens=2 delims==" %%b in ('%_7z% l "%%f" ^| findstr /c:"Comment ="') do (
            set DYNLABEL=%%b
        )
		:: Remove leading space from label
        for /f "tokens=* delims= " %%a in ("!DYNLABEL!") do set DYNLABEL=%%a
        :: Set the flag to indicate that the first ISO has been processed
        if defined DYNLABEL set found=1
    )
)

:: Loop through the ISO files in the folder
if !found! neq 1 for %%f in ("%folder%\*.iso") do (
    if !found! equ 0 (
        :: Run 7z to list the archive contents and search for the Comment field
        for /f "tokens=2 delims=:" %%b in ('%_7z% l "%%f" ^| findstr /c:"LogicalVolumeId:"') do (
            set DYNLABEL=%%b
        )
		:: Remove leading space from label
        for /f "tokens=* delims= " %%a in ("!DYNLABEL!") do set DYNLABEL=%%a
        :: Set the flag to indicate that the first ISO has been processed
        if defined DYNLABEL set found=1
    )
)

:: Set label if label is not defined
if defined DYNLABEL (
    set "LABEL=%DYNLABEL%"
) else (
    set LABEL=%LABEL%
)
exit /b

:getfsobjsize
:: Arguments: %1 = Path, %2 = Variable to store size
set "target=%~1"
set "%2=0"

if exist "%target%" (
    if exist "%target%\" (
        :: It's a directory
        pushd "%~1" || goto :EOF
        for /f "tokens=2 delims= " %%a in ('robocopy "%CD%" "%TEMP%" /S /L /BYTES /XJ /NFL /NDL /NJH /R:0 ^| find "Bytes"') do set "%2=%%a"
        popd
    ) else (
        :: It's a file
        for %%A in ("%target%") do (
            set "%2=%%~zA"
        )
    )
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Target "%target%" does not exist. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    set "%2=0"
)
exit /b

:splitwim
:: Split the install.wim into install.swm files (each <4GB)
set installwimsize=0
call :getfsobjsize "Work\sources\%WIMFILE%" installwimsize
if !installwimsize! geq 4194304000 (
    echo Splitting Work\sources\%WIMFILE% into .swm files in Work\sources\install.swm... | "%_tee%" -a "%LOG_FILE%"
    dism /Split-Image /ImageFile:"Work\sources\%WIMFILE%" /SWMFile:"Work\sources\install.swm" /FileSize:4000 /checkintegrity | "%_tee%" -a "%LOG_FILE%"
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to split Work\sources\%WIMFILE% | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    if exist "Work\sources\install.swm" (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO Work\sources\%WIMFILE% split successfully! | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        del /q "Work\sources\%WIMFILE%"
    ) else (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Split failed, install.swm not found. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
) else (
    call :getfileext "Work\sources\%WIMFILE%"
    set fileExt=!fileExt!
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Install %fileExt% file does not need split, file size too small! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
)
exit /b

:splitbootwim
:: Split the boot.wim into boot.swm files (each <4GB)
set bootwimsize=0
call :getfsobjsize %CD%\Work\sources\%BOOTFILE% bootwimsize
if !bootwimsize! geq 4194304000 (
    echo Splitting Work\sources\%BOOTFILE% into .swm files in Work\sources\boot.swm... | "%_tee%" -a "%LOG_FILE%"
    dism /Split-Image /ImageFile:"Work\sources\%BOOTFILE%" /SWMFile:"Work\sources\boot.swm" /FileSize:4000 /CheckIntegrity | "%_tee%" -a "%LOG_FILE%"
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to split Work\sources\%BOOTFILE% | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    if exist "Work\sources\boot.swm" (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO Work\sources\%BOOTFILE% split successfully! | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        del /q "Work\sources\%BOOTFILE%"
    ) else (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Split failed, boot.swm not found. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
) else (
    call :getfileext "Work\sources\%BOOTFILE%"
    set fileExt=!fileExt!
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Boot %fileExt% file does not need split, file size too small! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
)
exit /b

:adddrivers
:: Step 1: Check if there are drivers in the drivers folder and exit if not
:: Check if the directory exists
if not exist "%DRIVER_PATH%" (
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Path .\Drivers does not exist! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Step 2: Count the number of files and directories in the specified directory
set "count=0"
for /f %%A in ('dir /a /b "%DRIVER_PATH%" 2^>nul ^| find /v /c ""') do set "count=%%A"

:: Step 3: Check if the directory is empty
if %count% equ 0 (
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Driver path is empty! Bypassing step. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	exit /b
)

:: Step 4: Create the mount directory if it doesn't exist
if not exist %MOUNT_DIR% mkdir %MOUNT_DIR%

:: Step 5: Get path of install.wim file and convert it if necessary
call :getfileext Work\Sources\%WIMFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .esd file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :esdtowim Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .esd to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
	set "Conv_ESD_Opt=1"
    set WIMFILE=install.wim
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set WIMFILE=install.wim
    set Split_WIM_Opt=1
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%WIMFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Step 6: Get path of boot.wim file and convert it if necessary
call :getfileext Work\Sources\%BOOTFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .esd file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :esdtowim Work\sources\%BOOTFILE% Work\sources\boot.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .esd to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
	set Conv_BESD_Opt=1
    set BOOTFILE=boot.wim
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%BOOTFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%BOOTFILE% Work\sources\boot.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set BOOTFILE=boot.wim
    set set "Split_Boot_WIM_Opt=1"
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%BOOTFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)


:: Step 7: Get the number of images in the Install WIM file
for /L %%A IN (1, 1, 25) Do (
dism /Get-WimInfo /WimFile:"Work\sources\%WIMFILE%" /index:%%A > %CD%\TEMP\%%A
timeout 0 >nul
Find /i "Error:" "%CD%\TEMP\%%A" > nul && (
     set "Index=%%A"
       goto:setinstallimagecount
) 
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO ERROR: Failed to get image count from Work\sources\%WIMFILE% | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b 1
:setinstallimagecount
set /A INSTALL_IMAGE_COUNT = %Index% - 1

for /L %%A in (1, 1, %Index%) do (
    del /q %CD%\TEMP\%%A
)

echo Number of images detected in install.wim: %INSTALL_IMAGE_COUNT% | "%_tee%" -a "%LOG_FILE%"

:: Step 8: Get the number of images in the Boot WIM file
for /L %%A IN (1, 1, 25) Do (
dism /Get-WimInfo /WimFile:"Work\sources\%BOOTFILE%" /index:%%A > %CD%\TEMP\%%A
timeout 0 >nul
Find /i "Error:" "%CD%\TEMP\%%A" > nul && (
     set "Index=%%A"
       goto:setbootimagecount
) 
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO ERROR: Failed to get image count from Work\sources\%BOOTFILE% | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b 1
:setbootimagecount
set /A BOOT_IMAGE_COUNT = %Index% - 1

for /L %%A in (1, 1, %Index%) do (
    del /q %CD%\TEMP\%%A
)

echo Number of images detected in boot.wim: %BOOT_IMAGE_COUNT% | "%_tee%" -a "%LOG_FILE%"

:: Step 9: Loop through each image in install and commit drivers
for /L %%i in (1,1,%INSTALL_IMAGE_COUNT%) do (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Mounting image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    :: Mount image
    dism /Mount-Wim /WimFile:Work\sources\%WIMFILE% /index:%%i /MountDir:%MOUNT_DIR% | "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to mount image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )

    :: Step 10: Add drivers to the mounted image
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Adding drivers to image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    dism /Image:%MOUNT_DIR% /Add-Driver /Driver:%DRIVER_PATH% /Recurse | "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to add drivers to image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )

    :: Step 11: Commit changes and unmount the image
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Committing changes to image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    dism /Unmount-Wim /MountDir:%MOUNT_DIR% /Commit /CheckIntegrity | "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to commit changes for image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )
)

:: Step 13: Loop through each image in boot and commit drivers
for /L %%i in (1,1,%BOOT_IMAGE_COUNT%) do (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Mounting image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    :: Mount image
    dism /Mount-Wim /WimFile:Work\sources\%BOOTFILE% /index:%%i /MountDir:%MOUNT_DIR% | "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to mount image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )

    :: Step 14: Add drivers to the mounted image
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Adding drivers to image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    dism /Image:%MOUNT_DIR% /Add-Driver /Driver:%DRIVER_PATH% /Recurse | "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
	    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to add drivers to image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )

    :: Step 15: Commit changes and unmount the image
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Committing changes to image %%i | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    dism /Unmount-Wim /MountDir:%MOUNT_DIR% /Commit /CheckIntegrity| "%_tee%" -a "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% NEQ 0 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to commit changes for image %%i. Exiting. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b %ERRORLEVEL%
    )
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO All drivers have been committed successfully. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b

:getfileext
:: Set the file path to check
set "filePath=%1"

:: Extract the file extension
for %%F in ("%filePath%") do set "fileExt=%%~xF"

:: Convert to lowercase for comparison (optional, batch is case-insensitive)
:: Remove the leading dot
set "fileExt=%fileExt:~1%"

:: Check the extension
if /i "%fileExt%" == "wim" (
    :: echo The file is a .wim file. | "%_tee%" -a "%LOG_FILE%"
    exit /b 0
) else if /i "%fileExt%" == "esd" (
    :: echo The file is a .esd file. | "%_tee%" -a "%LOG_FILE%"
    exit /b 0
) else if /i "%fileExt%" == "swm" (
    :: echo The file is a .swm file. | "%_tee%" -a "%LOG_FILE%"
    exit /b 0
) else (
    :: echo The file extension is not .wim, .esd, or .swm.
    exit /b 1
)

exit /b 1

:esdtowim
:: Set paths
set "sourceEsd=%1"
set "destinationWim=%2"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Converting ESD to WIM | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
:: Get total images in the ESD file
for /f "tokens=3" %%I in ('dism /Get-WimInfo /WimFile:"%sourceEsd%" ^| find "Index"') do (
    set "lastIndex=%%I"
)

:: Export all images
for /L %%I in (1,1,%lastIndex%) do (
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Exporting image index %%I... | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    dism /Export-Image /SourceImageFile:"%sourceEsd%" /SourceIndex:%%I /DestinationImageFile:"%destinationWim%" /Compress:max /CheckIntegrity | "%_tee%" -a "%LOG_FILE%"
)

if not exist "%destinationWim%" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: WIM file not created! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	exit /b 1
)

:: Delete source ESD file
del /q %sourceESD%
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Conversion from ESD to WIM complete! | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b

:wimtoesd
:: Set paths
set "sourceWim=%1"
set "destinationEsd=%2"

:: Use PowerShell to get total system memory in bytes
for /f %%a in ('powershell -Command "(Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1Gb"') do set "TotalMemory=%%a"

:: Extract the integer from the memory value
for /F "tokens=1 delims=." %%A in ("%TotalMemory%") do set TotalMemoryInt=%%A

:: Check if the system has 15GB or more of RAM (nominal 16)
if %TotalMemoryInt% geq 15 (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Converting WIM to ESD | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    :: Get total images in the WIM file
    for /f "tokens=3" %%I in ('dism /Get-WimInfo /WimFile:"%sourceWim%" ^| find "Index"') do (
        set "lastIndex=%%I"
    )
    
    :: Export all images
    for /L %%I in (1,1,%lastIndex%) do (
		ECHO. | "%_tee%" -a "%LOG_FILE%"
	    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO Exporting image index %%I... | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
        dism /Export-Image /SourceImageFile:"%sourceWim%" /SourceIndex:%%I /DestinationImageFile:"%destinationEsd%" /Compress:recovery /CheckIntegrity | "%_tee%" -a "%LOG_FILE%"
    )
    
    if not exist "%destinationEsd%" (
        ECHO. | "%_tee%" -a "%LOG_FILE%"
    	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: ESD file not created! | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    	ECHO. | "%_tee%" -a "%LOG_FILE%"
    	exit /b 1
    )
    
    :: Delete source WIM file
    del /q %sourceWim%
    
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Conversion from WIM to ESD complete! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO. | "%_tee%" -a "%LOG_FILE%"
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO This computer has less than 16GB RAM, skipping WIM to ESD. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO. | "%_tee%" -a "%LOG_FILE%"
)
exit /b

:convertswm
:: Set paths
set "sourceSwm=%1"
set "destinationWim=%2"
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Converting SWM to WIM... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
:: Get total images in the SWM file
for /f "tokens=3" %%I in ('dism /Get-WimInfo /WimFile:"%sourceSwm%" ^| find "Index"') do (
    set "lastIndex=%%I"
)

for /L %%i in (1,1,%lastIndex%) do (
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Exporting image index %%i.... | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    DISM /Export-Image /SourceImageFile:%sourceSwm% /SWMFile:%sourceSwm:~0,-4%*.swm /SourceIndex:%%i /DestinationImageFile:%destinationWim% /Compress:max /CheckIntegrity
    if errorlevel 1 (
        ECHO. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to export image index %%i. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
)


if not exist "%destinationWim%" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: WIM file not created! | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	exit /b 1
)

:: Delete all SWM files in source directory
del /q %sourceSwm%
del /q %sourceSwm:~0,-4%*.swm

ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Conversion from SWM to WIM complete! | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b

:disablebitlocker
:: Step 1: Create the mount directory if it doesn't exist
if not exist %MOUNT_DIR% mkdir %MOUNT_DIR%

:: Step 2: Get path of install.wim file and convert it if necessary
call :getfileext Work\Sources\%WIMFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .esd file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :esdtowim Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .esd to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
	set "Conv_ESD_Opt=1"
    set WIMFILE=install.wim
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set WIMFILE=install.wim
    set Split_WIM_Opt=1
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%WIMFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Step 3: Get the number of images in the Install WIM file
for /L %%A IN (1, 1, 25) Do (
dism /Get-WimInfo /WimFile:"Work\sources\%WIMFILE%" /index:%%A > %CD%\TEMP\%%A
timeout 0 >nul
Find /i "Error:" "%CD%\TEMP\%%A" > nul && (
     set "Index=%%A"
       goto:setinstallimagecountbit
)
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO ERROR: Failed to get image count from Work\sources\%WIMFILE% | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b 1
:setinstallimagecountbit
set /A INSTALL_IMAGE_COUNT = %Index% - 1

for /L %%A in (1, 1, %Index%) do (
    del /q %CD%\TEMP\%%A
)

echo Number of images detected in install.wim: %INSTALL_IMAGE_COUNT% | "%_tee%" -a "%LOG_FILE%"

:: Step 4: Loop through each image in install and modify registry
for /L %%i in (1,1,%INSTALL_IMAGE_COUNT%) do (
	%_wimlib% extract "WORK\sources\install.wim" %%i \Windows\System32\config\SYSTEM --no-acls --no-attributes --dest-dir="TEMP" | "%_tee%" -a "%LOG_FILE%"

    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Adding PreventDeviceEncryption registry to image %%i: | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    SET "ACF=HKLM\MDL_Test\ControlSet001\Control\BitLocker"
    Reg.exe load HKLM\MDL_Test "TEMP\SYSTEM" | "%_tee%" -a "%LOG_FILE%"
    Reg.exe add "%ACF%\HwReqChk" /v PreventDeviceEncryption /t REG_DWORD /d 1 /f | "%_tee%" -a "%LOG_FILE%"
    Reg.exe unload HKLM\MDL_Test | "%_tee%" -a "%LOG_FILE%"

%_wimlib% update "WORK\sources\install.wim" %%i --command="add 'TEMP\SYSTEM' '\Windows\System32\config\SYSTEM'" | "%_tee%" -a "%LOG_FILE%"
)
exit /b

:disablemsaccount
:: Step 1: Create the mount directory if it doesn't exist
if not exist %MOUNT_DIR% mkdir %MOUNT_DIR%

:: Step 2: Get path of install.wim file and convert it if necessary
call :getfileext Work\Sources\%WIMFILE%
set fileExt=!fileExt!
if /i "%fileExt%" == "wim" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .wim file, no conversion needed. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
) else if /i "%fileExt%" == "esd" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .esd file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :esdtowim Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .esd to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
	set "Conv_ESD_Opt=1"
    set WIMFILE=install.wim
) else if /i "%fileExt%" == "swm" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Work\sources\%WIMFILE% is a .swm file, converting into a wim file. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    call :convertswm Work\sources\%WIMFILE% Work\sources\install.wim
    if errorlevel 1 (
	    ECHO. | "%_tee%" -a "%LOG_FILE%"
		ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
        ECHO ERROR: Failed to convert .swm to .wim. | "%_tee%" -a "%LOG_FILE%"
        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
		ECHO. | "%_tee%" -a "%LOG_FILE%"
        exit /b 1
    )
    set WIMFILE=install.wim
    set Split_WIM_Opt=1
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Work\sources\%WIMFILE% is not .wim, .esd, or .swm. | "%_tee%" -a "%LOG_FILE%"
    ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
)

:: Step 3: Get the number of images in the Install WIM file
for /L %%A IN (1, 1, 25) Do (
dism /Get-WimInfo /WimFile:"Work\sources\%WIMFILE%" /index:%%A > %CD%\TEMP\%%A
timeout 0 >nul
Find /i "Error:" "%CD%\TEMP\%%A" > nul && (
     set "Index=%%A"
       goto:setinstallimagecountmsa
) 
)
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO ERROR: Failed to get image count from Work\sources\%WIMFILE% | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
exit /b 1
:setinstallimagecountmsa
set /A INSTALL_IMAGE_COUNT = %Index% - 1

for /L %%A in (1, 1, %Index%) do (
    del /q %CD%\TEMP\%%A
)

echo Number of images detected in install.wim: %INSTALL_IMAGE_COUNT% | "%_tee%" -a "%LOG_FILE%"

:: Step 4: Loop through each image in install and modify registry
for /L %%i in (1,1,%INSTALL_IMAGE_COUNT%) do (
	%_wimlib% extract "WORK\sources\install.wim" %%i \Windows\System32\config\SOFTWARE --no-acls --no-attributes --dest-dir="TEMP" | "%_tee%" -a "%LOG_FILE%"

    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Adding BypassNRO registry to image %%i: | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
	SET "ACF=HKLM\MDL_Test\Microsoft\Windows\CurrentVersion"
    Reg.exe load HKLM\MDL_Test "TEMP\SOFTWARE" | "%_tee%" -a "%LOG_FILE%"
	Reg.exe add "%ACF%\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f | "%_tee%" -a "%LOG_FILE%"
    Reg.exe unload HKLM\MDL_Test | "%_tee%" -a "%LOG_FILE%"

    %_wimlib% update "WORK\sources\install.wim" %%i --command="add 'TEMP\SOFTWARE' '\Windows\System32\config\SOFTWARE'" | "%_tee%" -a "%LOG_FILE%"
)
exit /b

:checkmounted
rem Expand the folder path to its full path
set "fullPath=%~f1"
rem Get drive letter of path
for /f "tokens=1 delims=\" %%a in ("%fullPath%") do set "drive=%%a"

rem Run the dism command and capture its output
for /f "tokens=3 delims=:" %%A in ('dism /Get-MountedWimInfo ^| findstr /i "Mount Dir"') do (
    rem Remove leading and trailing spaces from the extracted value
    for /f "tokens=*" %%B in ("%%A") do (
        set "mountDir=%%B"
        rem Check if the mountDir is the one we want
        if /i "%drive%%%B"=="%fullPath%" (
			ECHO. | "%_tee%" -a "%LOG_FILE%"
	        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
            ECHO Image mounted in %MOUNT_DIR%, unmounting... | "%_tee%" -a "%LOG_FILE%"
	        ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	        ECHO. | "%_tee%" -a "%LOG_FILE%"
            goto :unmountwimifmounted
        )
    )
)

rem If the desired mount directory is not found
goto :endunmount

:unmountwimifmounted
dism /Unmount-Wim /MountDir:%fullPath% /Discard
if exist "%fullPath%\*" (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO ERROR: Unmounting failed! Please manually clean up. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
    exit /b 1
) else (
    ECHO. | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
    ECHO Unmounted %MOUNT_DIR% successfully! | "%_tee%" -a "%LOG_FILE%"
	ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
	ECHO. | "%_tee%" -a "%LOG_FILE%"
)

:endunmount
exit /b

:offlineinsiderenroll
ECHO. | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO Copying OfflineInsiderEnroll.cmd to ISO dir... | "%_tee%" -a "%LOG_FILE%"
ECHO ============================================================= | "%_tee%" -a "%LOG_FILE%"
ECHO. | "%_tee%" -a "%LOG_FILE%"
COPY /Y "Files\OfflineInsiderEnroll.cmd" "WORK\" | "%_tee%" -a "%LOG_FILE%"
exit /b