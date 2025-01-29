@echo off
TITLE Admin Check...
ECHO Checking for admin...

reg query HKU\S-1-5-19 1>nul 2>nul && goto :gotAdmin
if not "%1"=="am_admin" (powershell start -verb runas '%0' am_admin & exit /b)

:gotAdmin
cls
TITLE Online Upgrade Enabler
echo.
echo ===================================================================
echo.
echo Run this command only when you're performing a 24H2
echo ISO upgrade on unsupported hardware!!!
echo.
echo ===================================================================
:choice
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto :RUN
if /I "%c%" EQU "N" goto :EOF
goto :choice
echo.
:Run
:Mod_OS_Reg
ECHO.
ECHO =============================================================
ECHO Adding HwReqChkVars registry for Current OS
ECHO ^(Bypass CPU-Disksize-RAM-TPM-Secureboot checks for upgrade^)
ECHO =============================================================
ECHO.
SET "ACF=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags"
Reg.exe delete "%ACF%\CompatMarkers" /f 1>nul 2>nul
Reg.exe delete "%ACF%\Shared" /f 1>nul 2>nul
Reg.exe delete "%ACF%\TargetVersionUpgradeExperienceIndicators" /f 1>nul 2>nul
Reg.exe add "%ACF%\HwReqChk" /f /v "HwReqChkVars" /t REG_MULTI_SZ /s "," /d "SQ_SSE2ProcessorSupport=TRUE,SQ_SSE4_2ProcessorSupport=TRUE,SQ_NXProcessorSupport=TRUE,SQ_CompareExchange128=TRUE,SQ_LahfSahfSupport=TRUE,SQ_PrefetchWSupport=TRUE,SQ_PopCntInstructionSupport=TRUE,SQ_SecureBootCapable=TRUE,SQ_SecureBootEnabled=TRUE,SQ_TpmVersion=2,SQ_RamMB=9999,SQ_SystemDiskSizeMB=99999,SQ_CpuCoreCount=9,SQ_CpuModel=99,SQ_CpuFamily=99,SQ_CpuMhz=9999," 1>nul 2>nul
if %errorlevel% equ 0 (echo The operation completed successfully.) else (The operation failed.)
Reg.exe add "HKLM\SYSTEM\Setup\MoSetup" /f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d "1" 1>nul 2>nul
if %errorlevel% equ 0 (echo The operation completed successfully.) else (The operation failed.)
pause
exit /b