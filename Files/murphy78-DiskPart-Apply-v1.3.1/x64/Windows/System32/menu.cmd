@ECHO OFF
pushd %~dp0
SetLocal EnableDelayedExpansion

:color and title
color 1f
title murphy78's DiskPart and Apply Image Script 1.3.1

:Set some defaults for later
set DISK=0
set WINRE=1
set MULTIBOOT=0
set NOSYSPART=0
set DISKPREPARED=0
set ERRORTEMP=0
set MAXPART=0
set FASTSETUP=0
set ISACTIVE=0

:INITIALIZATION SECTION
:Firstly, make sure there is an install image
:Use a set var="" else the IF NOT EXIST statement will crash the script
SET INSTALLIMAGE=""
SET SPLIT=0

FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.wim" SET INSTALLIMAGE="%%i:\Sources\install.wim"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.esd" SET INSTALLIMAGE="%%i:\Sources\install.esd"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\Sources\install.swm" SET INSTALLIMAGE="%%i:\Sources\install.swm"&SET SPLIT=1&SET SPLITPATTERN="%%i:\Sources\install*.swm"&GOTO :SETUPCHECK)

IF EXIST X:\Windows\SysWow64 (
GOTO :IMG64
)

:IMG32
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x86\Sources\install.wim" SET INSTALLIMAGE="%%i:\x86\Sources\install.wim"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x86\Sources\install.esd" SET INSTALLIMAGE="%%i:\x86\Sources\install.esd"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x86\Sources\install.swm" SET INSTALLIMAGE="%%i:\x86\Sources\install.swm"&SET SPLIT=1&SET SPLITPATTERN="%%i:\x86\Sources\install*.swm"&GOTO :SETUPCHECK)
GOTO :NOIMAGE

:IMG64
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x64\Sources\install.wim" SET INSTALLIMAGE="%%i:\x64\Sources\install.wim"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x64\Sources\install.esd" SET INSTALLIMAGE="%%i:\x64\Sources\install.esd"&GOTO :SETUPCHECK)
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST "%%i:\x64\Sources\install.swm" SET INSTALLIMAGE="%%i:\x64\Sources\install.swm"&SET SPLIT=1&SET SPLITPATTERN="%%i:\x64\Sources\install*.swm"&GOTO :SETUPCHECK)

:IF none of the install.wim, esd, or swm, files were found in a sources\ directory, bail this failboat
:NOIMAGE
IF NOT EXIST !INSTALLIMAGE! (
CLS
ECHO ===============================================================================
ECHO.                          NO IMAGE DETECTED
ECHO -------------------------------------------------------------------------------
ECHO Setup could not find an install.wim, esd, or swm file.
ECHO -------------------------------------------------------------------------------
pause
GOTO :QUIT)

:Next check to see if someone added script to an existing setup boot.wim
:If copied to an existing boot.wim give option to opt-out
:WinPE file winpeshl.ini should list setup.exe next in apps
:SETUPCHECK
ECHO Scanning !INSTALLIMAGE! to create the index list file. Please Wait...
IF EXIST X:\IMAGELIST.TXT DEL /q /s X:\IMAGELIST.TXT
for /f "tokens=2 delims=: " %%a in ('dism /Get-WimInfo /WimFile:!INSTALLIMAGE! ^| find /i "Index"') do (
for /f "tokens=2 delims=:" %%g in ('dism /Get-WimInfo /WimFile:!INSTALLIMAGE! /Index:%%a ^| find /i "Name"') do (ECHO %%a.%%g>>X:\IMAGELIST.TXT))
IF NOT EXIST X:\Setup.exe GOTO :UEFICHECK
CLS
ECHO -------------------------------------------------------------------------------
ECHO Welcome to the murphy78 Diskpart/Apply Image Script.
ECHO This script uses Microsoft functions to format a drive and
ECHO install a setup medium. The script is also capable of setting
ECHO up a dual-boot system provided both indexes are on the install
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "(Y)es to use script, or (N)o to use Windows Setup: "
IF !ERRORLEVEL! EQU 2 (exit)



:Lastly do the UEFI detection
:UEFICHECK
:Check whether user has booted with UEFI or BIOS and set UEFI=1 if UEFI
wpeutil UpdateBootInfo
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
:: Note: delims is a TAB followed by a space.
if !Firmware!==0x1 set UEFI=0
if !Firmware!==0x2 set UEFI=1


:MAINMENU
CLS
IF NOT "!CD!"=="%~dp0" cd /D "%~dp0"
IF !NOSYSPART! EQU 1 SET WINRE=0
ECHO ===============================================================================
ECHO.                                 MAIN MENU
ECHO ===============================================================================
ECHO.        A. - ^(A^)dd Drivers or Re-Initialize WinPE
ECHO.        C. - ^(C^)ommand Prompt
:: Only display these option in BIOS boot
IF !UEFI! EQU 0 (
   ECHO -------------------------------------------------------------------------------
   ECHO.        N. - ^(N^)o extra system partition *MBR/BIOS-Boot only*
   ECHO.        W. - ^(W^)inre.wim copy Option
)
ECHO -------------------------------------------------------------------------------
ECHO.        D. - ^(D^)isk selection
ECHO.        S. - ^(S^)etup Windows with choices and Multi-Boot options
ECHO.        F. - ^(F^)ast Single-Install Setup only choosing Install Index
IF EXIST X:\sources\recovery\recenv.exe (
ECHO -------------------------------------------------------------------------------
ECHO.        R. - ^(R^)epair menu
)
ECHO ===============================================================================
if !UEFI! EQU 1 ( 
   ECHO.        * Disk !DISK! with GPT partitioning ^(UEFI-Booting Detected^) *
) ELSE (
:: Only display these flags in BIOS boot
   ECHO.        * Disk !DISK! with MBR partitioning ^(BIOS-Legacy Detected^) *
   IF !WINRE! EQU 1 ( 
      ECHO.        * WINRE.WIM Copy ENABLED *
   ) ELSE (
      ECHO.        * WINRE.WIM Copy DISABLED *
   )
   IF !NOSYSPART! EQU 1 (
      ECHO.        * NO System Partition ENABLED *
   ) ELSE ( 
      ECHO.        * NO System Partition DISABLED *
   )
)

ECHO ===============================================================================

choice /c acnwdsfrq /n /m "Choose a menu option, or Q to Quit: "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (GOTO :SelectionA)
IF !ERRORTEMP! EQU 2 (GOTO :SelectionC)
IF !ERRORTEMP! EQU 3 (GOTO :SelectionN)
IF !ERRORTEMP! EQU 4 (GOTO :SelectionW)
IF !ERRORTEMP! EQU 5 (GOTO :SelectionD)
IF !ERRORTEMP! EQU 6 (GOTO :SelectionS)
IF !ERRORTEMP! EQU 7 (GOTO :SelectionF)
IF !ERRORTEMP! EQU 8 (GOTO :SelectionR)
IF !ERRORTEMP! EQU 9 (GOTO :QUIT)
GOTO :MAINMENU

:SelectionD
GOTO :DISKMENU

:SelectionW
IF !UEFI! EQU 1 GOTO :MAINMENU
ECHO -------------------------------------------------------------------------------
ECHO Windows normally copies the WinRE.WIM recovery file to a separate partition.
ECHO Unless you enable the MBR optional No System Partition option, it will
ECHO still create a system partition; it will just be 100MB instead of 1000MB.
ECHO ALL subsequent multi-boot setups will have this WinRE copy disabled.
ECHO.
ECHO [Y] - Yes, I want to set this option.
ECHO [N] - No, take me back to the main menu.
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "Would you like to CHANGE the WINRE movement flag? (Y/N): "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (IF !WINRE! EQU 0 (
SET NOSYSPART=0
SET WINRE=1) ELSE IF !WINRE! EQU 1 (SET NOSYSPART=0
SET WINRE=0)
)
IF !ERRORTEMP! EQU 2 (GOTO :MAINMENU)
GOTO :MAINMENU

:SelectionN
:: Go back to menu if UEFI mode. Option not available
IF !UEFI! EQU 1 GOTO :MAINMENU
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO Windows normally creates a separate SYSTEM partition
ECHO MBR partitioning is limited on primary partitions per drive
ECHO By default the extra partition is created
ECHO.
ECHO [Y] - Yes, I want to set this option.
ECHO [N] - No, take me back to the main menu.
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "Would you like to change the No System Partition option? (Y/N): "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (IF !NOSYSPART! EQU 0 (SET NOSYSPART=1
GOTO :MAINMENU)
IF !NOSYSPART! EQU 1 (SET NOSYSPART=0
GOTO :MAINMENU))
GOTO :MAINMENU

:SelectionC
START CMD
GOTO :MAINMENU

:SelectionR
IF NOT EXIST X:\sources\recovery\recenv.exe GOTO :MAINMENU
START X:\sources\recovery\recenv.exe
GOTO :MAINMENU

:SelectionA
CLS
ECHO -------------------------------------------------------------------------------
ECHO Would you like to add a driver to the Windows PE? Note that the Drivers need
ECHO to be compatible with this WINPE Image. Example: Raid driver or USB3 driver
ECHO You can also choose I to Initialize any Plug and Play devices.
ECHO.
ECHO [Y] - Yes, I want to add a driver or driver path to WinPE.
ECHO [N] - No, take me back to the main menu.
ECHO [I] - Reinitialize WinPE ^(call WPEINIT^)
ECHO -------------------------------------------------------------------------------
choice /c yin /n /m "Add Driver? (Y)es, (N)o, or (I)nitialize: "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 2 (ECHO.
ECHO Initializing...
WPEINIT
GOTO :SelectionA)
IF !ERRORTEMP! EQU 3 (GOTO :MAINMENU)
IF !ERRORTEMP! EQU 0 GOTO :SelectionA

ECHO -------------------------------------------------------------------------------
ECHO Use the folder, separate multiples with comma:
ECHO Example: D:\x64\ahci86s.inf,D:\x64-2\ahci86w.inf
ECHO.
ECHO If given a directory, the command will recurse to load ALL INF files it finds.
ECHO You can use the cmd prompt to locate the file name and path
ECHO -------------------------------------------------------------------------------
:: SET /P is fine if using SetLocal EnableDelayedExpansion
:SelectionAChoice2
set INPUT=
set /P INPUT="Please type the path, [C] for CMD or [Q] to go back: " || set INPUT=
IF [!INPUT!]==[] GOTO :SelectionAChoice2
IF /I [!INPUT!]==[Q] GOTO :MAINMENU
IF /I [!INPUT!]==[C] (
   START CMD
   GOTO :SelectionA
)
ECHO Attempting to add driver from [!INPUT!]
IF NOT EXIST "!INPUT!" GOTO :SelectionAError
:: Yes, this weird line will only continue on a directory.
:: || is "if previous command fails"
:: Putting commands in parentheses means it'll evaluate all commands
:: This is a hack to avoid using ERRORLEVEL since I don't think it's reliable...
:: ...when we use EnableDelayedExpansion
((dir /A:D "!INPUT!" >Nul 2>&1) && (
   pushd "!INPUT!"
   FOR /R %%G IN (*.inf) DO (
      echo Adding [%%G]...
      drvload "%%~fG" || echo WARNING: Could not load [%%G]
   )
   popd
)) || ( drvload "!INPUT!" && ( (ECHO.) & PAUSE ) ) || GOTO :SelectionAError
GOTO :SelectionA

:SelectionAError
ECHO ERROR: [!INPUT!] does not exist or DRVLOAD had errors.
Echo Check path and spelling.
ECHO Press any key to go back to the WinPE Driver menu.
pause >Nul
GOTO :SelectionA

:SelectionS
GOTO :SETUP

:SelectionF
ECHO -------------------------------------------------------------------------------
ECHO Fast Setup will clean disk !DISK! and only prompt you for an Install Index.
ECHO.
ECHO [Y] - Yes, use Fast Setup.
ECHO [N] - No, take me back to the main menu.
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "(Y)es, (N)o? "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (
SET FASTSETUP=1
GOTO :SETUP)

IF !ERRORTEMP! EQU 2 GOTO :MAINMENU

GOTO :SelectionF

:DISKMENU
CLS
ECHO ===============================================================================
ECHO.                   SELECT YOUR DISK NUMBER ^(Default: 0^):
ECHO -------------------------------------------------------------------------------
ECHO List Disk|diskpart
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO Select a disk number ^(0-9^)
ECHO [V] to List Disk Volumes
ECHO [Q] to Quit to the Main Menu
ECHO -------------------------------------------------------------------------------
ECHO Note that disk 0 is the first disk, and they might not appear in order.
ECHO Current DISK selected is ^( %DISK% ^)
choice /c 0123456789VQ /n /m "Choose a number, (V) or (Q): "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (SET DISK=0)
IF !ERRORTEMP! EQU 2 (SET DISK=1)
IF !ERRORTEMP! EQU 3 (SET DISK=2)
IF !ERRORTEMP! EQU 4 (SET DISK=3)
IF !ERRORTEMP! EQU 5 (SET DISK=4)
IF !ERRORTEMP! EQU 6 (SET DISK=5)
IF !ERRORTEMP! EQU 7 (SET DISK=6)
IF !ERRORTEMP! EQU 8 (SET DISK=7)
IF !ERRORTEMP! EQU 9 (SET DISK=8)
IF !ERRORTEMP! EQU 10 (SET DISK=9)
IF !ERRORTEMP! EQU 11 (GOTO :DISKSelectionV)
IF !ERRORTEMP! EQU 12 (GOTO :MAINMENU)

:VERIFY DISK EXISTS ELSE GO BACK AND TRY AGAIN
ECHO LIST DISK | DISKPART | find /i "Disk !DISK!" >NUL
IF !ERRORLEVEL! NEQ 0 (
ECHO.
ECHO DISK !DISK! is returning errors.
ECHO Press any key to return to Disk Selection.
ECHO.
SET DISK=0
PAUSE>NUL
GOTO :DISKMENU
)
GOTO :DISKMENU

:DISKSelectionV
ECHO List Volume|diskpart
ECHO.
ECHO Press any key to return to the DISK MENU.
PAUSE > NUL & GOTO :DISKMENU


:SETUP
:THIS PART does the initial system and uefi partitions
CLS
:Skip display and options if fastsetup
IF !FASTSETUP! EQU 1 GOTO:WIPEPROCEED
IF !DISKPREPARED! EQU 1 (GOTO :DISKPREPMSG)
ECHO ===============================================================================
ECHO.                  DISK SYSTEM PARTITION PREPARATION OPTIONS
ECHO -------------------------------------------------------------------------------
ECHO.  Disk ###  Status         Size     Free     Dyn  Gpt
ECHO.  --------  -------------  -------  -------  ---  ---
ECHO LIST DISK | DISKPART | find /i "Disk !DISK!"
ECHO -------------------------------------------------------------------------------
ECHO Setup will now prepare Disk !DISK! for you.
ECHO Erase DISK !DISK! for you?
ECHO.
ECHO [Y] - Yes, Erase all data on DISK !DISK!
ECHO [K] - Keep existing Disk Partitions
ECHO [Q] - No, take me back to the main menu.
ECHO -------------------------------------------------------------------------------
choice /c ykq /m "(Y)es, (K)eep existing, or (Q)uit back to Main Menu? "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 GOTO :WIPEPROCEED
IF !ERRORTEMP! EQU 2 GOTO :USE-EXISTING-PARTITIONS
GOTO :MAINMENU

:USE-EXISTING-PARTITIONS
:First make sure that disk is GPT formatted if UEFI mode
ECHO LIST DISK|DISKPART|FIND /i "*">NUL
SET ERRORTEMP=!ERRORLEVEL!
IF !UEFI! EQU 1 (
IF !ERRORTEMP! NEQ 0 (
ECHO -------------------------------------------------------------------------------
ECHO DISK !DISK! is not GPT formatted and you are booting in UEFI mode.
ECHO You need to CLEAN the disk and convert to GPT if you wish to proceed.
ECHO -------------------------------------------------------------------------------
PAUSE
GOTO :SETUP
))
IF !UEFI! EQU 0 (
IF !ERRORTEMP! EQU 0 (
ECHO -------------------------------------------------------------------------------
ECHO DISK !DISK! is GPT formatted and you are booting in BIOS mode.
ECHO You need to CLEAN the disk and convert to MBR if you wish to proceed.
ECHO -------------------------------------------------------------------------------
PAUSE
GOTO :SETUP
))
SET DISKPREPARED=1
ECHO -------------------------------------------------------------------------------
IF !UEFI! EQU 0 (
ECHO This option will not create a System partition.
ECHO Are you sure you want to use the existing system partition?
)
IF !UEFI! EQU 1 (
ECHO This option will not create an EFI System or MSR Partition.
ECHO Are you sure you want to use the existing system partition?
)

ECHO.
ECHO [Y] Yes, I'm sure.
ECHO [N] No, take me back to the choices.
ECHO -------------------------------------------------------------------------------
choice /c YN /n /m "Use the Existing System Partition? (Y/N): "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 2 GOTO :SETUP
IF !UEFI! EQU 0 (SET WINRE=0
SET NOSYSPART=1)
GOTO :PARTITIONCREATION

:WIPEPROCEED
:start preparing the diskpart import script on the winpe ramdrive
ECHO SELECT DISK !DISK! >X:\DISKPART.TXT
ECHO CLEAN >>X:\DISKPART.txt
GOTO :POST-WIPE

:POST-WIPE
:GPT VERSION
IF !UEFI! EQU 1 (
ECHO Convert GPT >>X:\DISKPART.txt
ECHO create partition efi size=100 >>X:\DISKPART.txt
ECHO format quick fs=fat32 label="System" >>X:\DISKPART.txt
ECHO assign letter="S" >>X:\DISKPART.txt
ECHO create partition msr size=128 >>X:\DISKPART.txt)

:MBR VERSION
IF !UEFI! EQU 0 (
ECHO Convert MBR >>X:\DISKPART.txt
:IF WINRE movement flag is off in MBR mode and nosyspart is off,
:create a smaller system partition. IF nosyspart, don't make one
IF !NOSYSPART! EQU 0 (
IF !WINRE! EQU 1 (ECHO create partition primary size=1000 >>X:\DISKPART.txt)
IF !WINRE! EQU 0 (ECHO create partition primary size=100 >>X:\DISKPART.txt)
ECHO format quick fs=ntfs label="System" >>X:\DISKPART.txt
ECHO assign letter="W" >>X:\DISKPART.txt
ECHO Active >>X:\DISKPART.txt
SET ISACTIVE=1))

:Import the diskpart script
diskpart /s X:\diskpart.txt
set DISKPREPARED=1
GOTO :PARTITIONCREATION

:DISKPREPMSG
:This message is for people who have ran the initial disk prep and went back to main menu
ECHO.
ECHO ===============================================================================
ECHO.                     Disk Prep already ran.
ECHO -------------------------------------------------------------------------------
choice /c yn /m "Run Disk Preparation again? "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 1 (SET DISKPREPARED=0 & GOTO :SETUP)

:PARTITIONCREATION
CLS
:IF fast setup, use max partition and skip the choice
IF !FASTSETUP! EQU 1 (
ECHO SELECT DISK !DISK! >X:\DISKPART.TXT
IF !UEFI! EQU 1 (
ECHO create partition primary size=1000 >>X:\DISKPART.txt
ECHO format quick fs=ntfs label="Windows RE tools" >>X:\DISKPART.txt
ECHO assign letter="W" >>X:\DISKPART.txt
ECHO set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >>X:\DISKPART.txt
ECHO gpt attributes=0x8000000000000001 >>X:\DISKPART.txt)
ECHO CREATE PARTITION PRIMARY >>X:\DISKPART.TXT
SET MAXPART=1
GOTO :AFTERPARTCHOICE)

ECHO ===============================================================================
ECHO.                        WINDOWS PARTITION CREATION:
ECHO -------------------------------------------------------------------------------
ECHO Setup will create a Windows Partition for Windows install location
ECHO -------------------------------------------------------------------------------
ECHO.  Disk ###  Status         Size     Free     Dyn  Gpt
ECHO  --------  -------------  -------  -------  ---  ---
ECHO LIST DISK | DISKPART | find /i "Disk !DISK!"
ECHO.
ECHO Diskpart defaults to MegaByte size for partitions.
ECHO Use only Numbers - Example: 10000 ^(10 GB^), 100000 ^(100 GB^)
ECHO.
ECHO [M] Maximum partition Size
ECHO [E] Use an Existing Partition
ECHO [Q] Quit to Main Menu
ECHO -------------------------------------------------------------------------------
:DONT USE NESTED SET /P command, use goto: with errorlevel to avoid if desired
SET INPUT=
SET /P INPUT="Please enter a NUMBER, M for Max, E for existing, Q for Main Menu: "
IF NOT DEFINED INPUT GOTO :PARTITIONCREATION
IF /I '!INPUT!'=='E' GOTO :EXISTING-PARTITION-OPTION
IF /I '!INPUT!'=='Q' GOTO :MAINMENU
GOTO :PARTITIONSIZE

:EXISTING-PARTITION-OPTION
ECHO SELECT DISK !DISK! >X:\DISKPART.TXT
ECHO LIST PARTITION >>X:\DISKPART.TXT
DISKPART /S X:\DISKPART.TXT
ECHO.
ECHO -------------------------------------------------------------------------------
ECHO Select the Partition you wish to use, or Q to go back.
ECHO -------------------------------------------------------------------------------
SET INPUT=
SET /P INPUT="Please select a Partition or Q to return to go back: "
IF NOT DEFINED INPUT GOTO :EXISTING-PARTITION-OPTION
IF /I '!INPUT!'=='Q' GOTO :PARTITIONCREATION
for /f "tokens=1* delims=0123456789" %%a in ("A0%INPUT:"=%") do if not "%%b"=="" goto :EXISTING-PARTITION-OPTION
:verify that the partition exists
ECHO SELECT DISK !DISK! >X:\DISKPART.TXT
ECHO LIST PARTITION >>X:\DISKPART.TXT
DISKPART /S X:\DISKPART.TXT | FIND /i "Partition !INPUT!">NUL
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! NEQ 0 (
ECHO INVALID PARTITION NUMBER.
PAUSE
GOTO :EXISTING-PARTITION-OPTION
) ELSE (
SET WINRE=0
IF !UEFI! EQU 0 (SET NOSYSPART=1)
ECHO SELECT DISK !DISK! >X:\DISKPART.TXT
ECHO SELECT PARTITION !INPUT! >>X:\DISKPART.TXT
ECHO format quick fs=ntfs label="Windows" >>X:\DISKPART.txt
ECHO Assign Letter="Z" >>X:\DISKPART.txt

:Make the partition the active partition if BIOS-Boot
IF !UEFI! EQU 0 (
IF !ISACTIVE! EQU 0 (
ECHO -------------------------------------------------------------------------------
ECHO The first system partition on a MBR drive needs to be an Active partition.
ECHO If you set more than one Active partition, you will need to run bcdboot
ECHO after Setup on each of the Active drives like so:
ECHO bcdboot c:\windows
ECHO bcdboot d:\windows
ECHO.
ECHO If you have no previous Active partition, the script can set it for you.
ECHO -------------------------------------------------------------------------------
choice /c YN /m "Make this the Active MBR partition?"
set ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 2 GOTO :RUNDPEXISTING
ECHO ACTIVE >>X:\DISKPART.txt
SET ISACTIVE=1
))

:RUNDPEXISTING
DISKPART /S X:\DISKPART.TXT
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORLEVEL! NEQ 0 (
ECHO.
ECHO THERE WERE ERRORS FORMATTING THE PARTITION
ECHO.
PAUSE
GOTO :MAINMENU
)
GOTO :IMAGESELECTION
)

:PARTITIONSIZE

ECHO SELECT DISK !DISK! >X:\DISKPART.TXT

IF !UEFI! EQU 1 (
ECHO create partition primary size=1000 >>X:\DISKPART.txt
ECHO format quick fs=ntfs label="Windows RE tools" >>X:\DISKPART.txt
ECHO assign letter="W" >>X:\DISKPART.txt
ECHO set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >>X:\DISKPART.txt
ECHO gpt attributes=0x8000000000000001 >>X:\DISKPART.txt)

IF /I '!INPUT!'=='M' (
ECHO Max partition chosen.
ECHO There will be no room left on the disk for further installs.
Choice /c yn /m "Use the Maximum partition size? "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 2 GOTO :PARTITIONCREATION
SET MAXPART=1
ECHO CREATE PARTITION PRIMARY >>X:\DISKPART.TXT
) ELSE (
:Make sure only numbers were entered since not using M for maximum
for /f "tokens=1* delims=0123456789" %%a in ("A0%INPUT:"=%") do if not "%%b"=="" goto :PARTITIONCREATION

:SIZED PARTITION CREATION
:first make sure no letters, else kick it back to the partition menu
for /f "tokens=1* delims=0123456789" %%a in ("A0%INPUT:"=%") do if not "%%b"=="" GOTO :PARTITIONCREATION
ECHO You have entered: !INPUT!
ECHO This will make a partition of !INPUT! megabytes.
Choice /c yn /m "Partition size !INPUT!?"
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! EQU 2 GOTO :PARTITIONCREATION


ECHO CREATE PARTITION PRIMARY SIZE=!INPUT! >>X:\DISKPART.TXT
:Skip numbers-only check since M for max.
GOTO :AFTERPARTCHOICE)


:AFTERPARTCHOICE
:If no System Partition is being created, Make it active first time ran.
IF !NOSYSPART! EQU 1 (
ECHO Active >>X:\DISKPART.txt
SET NOSYSPART=0)

:Format the windows partition
ECHO format quick fs=ntfs label="Windows" >>X:\DISKPART.txt
ECHO Assign Letter="Z" >>X:\DISKPART.txt


:Execute the partition creation script
diskpart /s X:\DISKPART.txt
IF !ERRORLEVEL! NEQ 0 (
ECHO.
ECHO There were errors reported during partition creation.
ECHO You could have selection too large of a partition.
ECHO You also could have too many partitions already, esp with MBR.
ECHO Press any key to go back to the MAIN MENU.
ECHO.
set MAXPART=0
pause>NUL
GOTO :MAINMENU)

:IMAGESELECTION
SET INDEX=
CLS
ECHO ===============================================================================
ECHO =============================== INDEX SELECTION ===============================

:Display-Indexes
:s1ave77's dism get-wiminfo loop. Thx s1ave77!
:Just swapped the findstr for a find /i "" so I wouldn't need to add findstr to the distribution
TYPE X:\IMAGELIST.TXT
ECHO.
ECHO ========================== SELECT INDEX OR Q TO EXIT ==========================
:DONT USE NESTED SET /P command, use goto: with errorlevel to avoid if desired
SET INPUT=
SET /P INPUT="Please select an Index Number or Q to exit to the Main Menu: "
IF NOT DEFINED INPUT GOTO :IMAGESELECTION
IF /I '!INPUT!'=='Q' (
SET FASTSETUP=0
GOTO :MAINMENU
)
SET INDEX=!INPUT!

:CheckIndex

ECHO.

dism /Get-WimInfo /WimFile:!INSTALLIMAGE! /index:!INDEX!
IF !ERRORLEVEL! NEQ 0 GOTO :IMAGESELECTION

:CONFIRMINDEX
choice /c yn /n /m "Are you sure you wish to use this index? (Y/N): "
IF !ERRORLEVEL! NEQ 1 GOTO :IMAGESELECTION
GOTO :APPLYIMAGE
:In case functions get moved

:APPLYIMAGE
CLS
ECHO ===============================================================================
ECHO.                              SETUP IS WORKING
ECHO -------------------------------------------------------------------------------
ECHO Script will now apply the !INSTALLIMAGE! Index !INDEX!.
ECHO This will take a while...
ECHO -------------------------------------------------------------------------------

:APPLY COMMAND
IF !SPLIT! EQU 1 (dism /Apply-Image /ImageFile:!INSTALLIMAGE! /swmfile:%SPLITPATTERN% /Index:!INDEX! /ApplyDir:Z:\
) ELSE (dism /Apply-Image /ImageFile:!INSTALLIMAGE! /Index:!INDEX! /ApplyDir:Z:\)
:Again minimal error-handling
IF !ERRORLEVEL! NEQ 0 (
Echo.
ECHO There was a problem applying the image.
ECHO Press any key to go back to the main menu.
Pause
GOTO :MAINMENU)

:Check for syswow64 for x64 $oem$ subfolder copy
IF EXIST Z:\Windows\syswow64 (set xsubcopy=1) else (set xsubcopy=0)


ECHO -------------------------------------------------------------------------------
:Attrib off the hidden system stuff so we can move winre and winrecfg can find it
ECHO.              Adding boot information to the System partition
:Copy boot files and set the BCD options
bcdboot Z:\Windows
ECHO -------------------------------------------------------------------------------

ECHO.
ECHO Setting up WinRE.WIM and the recovery option

IF EXIST W:\ (md W:\Recovery\WindowsRE
xcopy /hy Z:\windows\system32\recovery\winre.wim W:\Recovery\WindowsRE\
winrecfg /setreimage /path W:\Recovery\WindowsRE /target Z:\Windows /bootkey 3b00
GOTO :INSTALLDRIVERS)

:IF multi-booting or disabled winre movement, the winre stays where it's at
IF EXIST Z:\Windows\system32\Recovery\WinRE.wim (
winrecfg /setreimage /path Z:\Windows\system32\Recovery /target Z:\Windows /bootkey 3b00)

:INSTALLDRIVERS
:Ask if user wishes to add drivers to the Z:\Windows partition
:Drivers installation is not available with fastsetup
IF !FASTSETUP! EQU 1 GOTO :OEMFOLDERCOPY
:ADDDRIVERS
CLS
ECHO ===============================================================================
ECHO.                      ADD ^(SOME / MORE^) DRIVERS?
ECHO -------------------------------------------------------------------------------
ECHO Would you like to add a driver folder for the Windows installation?
ECHO You need to add things such as Raid drivers even if you already
ECHO added them to the WINPE session. ^(Signed only^)
ECHO Example: Raid drivers for Windows 7/2008r2
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "Add drivers to the Windows offline image? (Y/N): "
IF !ERRORLEVEL! NEQ 1 (GOTO :OEMFOLDERCOPY)
ECHO Just type the parent folder, Ex: D:\DRIVERS\x64
:DONT USE NESTED SET /P command, use goto: with errorlevel to avoid if desired
SET INPUT=
SET /P INPUT="Please type the path, C for CMD prompt,or Q to go back: "
IF NOT DEFINED INPUT GOTO :ADDDRIVERS
IF /I '!INPUT!'=='Q' GOTO :ADDDRIVERS
IF /I '!INPUT!'=='C' (START CMD & GOTO :ADDDRIVERS)
ECHO Attempting to add drivers from !INPUT!
dism /image:Z:\ /add-driver /driver:!INPUT! /recurse
:minimal error-handling
IF !ERRORLEVEL! NEQ 0 (Echo There was a problem attempting to add the drivers at !INPUT!
pause)
GOTO :ADDDRIVERS


:OEMFOLDERCOPY
:Use a set var="" else the IF NOT EXIST statement will crash the script
SET OEMFOLDER=""
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST %%i:\Sources\$OEM$\ SET OEMFOLDER=%%i:\Sources\$OEM$&GOTO :OEMPROCEED)

:don't like nested for loops but need these conditional on the architecture of the applied image
If !xsubcopy! equ 1 (
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST %%i:\x64\Sources\$OEM$\ SET OEMFOLDER=%%i:\x64\Sources\$OEM$&GOTO :OEMPROCEED)
)
If !xsubcopy! equ 0 (
FOR %%i IN (Z Y X W V U T S R Q P O N M L K J I H G F E D C B A) DO (IF EXIST %%i:\x86\Sources\$OEM$\ SET OEMFOLDER=%%i:\x86\Sources\$OEM$&GOTO :OEMPROCEED)
)
IF NOT EXIST %OEMFOLDER% GOTO :MULTIBOOTOPTION

:OEMPROCEED
:IF FASTMODE, copy the files if they exist and skip the choice
IF !FASTSETUP! EQU 1 GOTO:AFTEROEMCHOICE
ECHO ===============================================================================
ECHO.                  $OEM$ Folder was detected in your system
ECHO -------------------------------------------------------------------------------
ECHO Copy the files from %OEMFOLDER%?
ECHO -------------------------------------------------------------------------------
choice /c yn /n /m "Copy the $OEM$ folder contents to the current Windows Partition? (Y/N): "
IF !ERRORLEVEL! NEQ 1 GOTO :MULTIBOOTOPTION
:AFTEROEMCHOICE
:Your basic $OEM$ folders copy here; no frills
echo.
Echo Copying contents of %OEMFOLDER% to system partition
if exist %OEMFOLDER%\$$\ (xcopy %OEMFOLDER%\$$\* Z:\Windows\ /cherkyi)
if exist %OEMFOLDER%\$1\ (xcopy %OEMFOLDER%\$1\* Z:\ /cherkyi)

:MULTIBOOTOPTION
:Re-do the drive letters for multi-boot and cleanup


ECHO SELECT DISK !DISK! >X:\DISKPART.txt
ECHO SELECT VOLUME Z >>X:\DISKPART.txt
ECHO REMOVE LETTER=Z >>X:\DISKPART.txt
ECHO ASSIGN >>X:\DISKPART.txt
diskpart /s X:\DISKPART.txt

:Give option to create another partition and apply image, else quit
IF !MAXPART! EQU 1 GOTO :QUIT
CLS
ECHO ===============================================================================
ECHO.                      SETUP COMPLETE - MULTI-BOOT?
ECHO -------------------------------------------------------------------------------
ECHO Would you like to create another partition and setup Multi-Boot?
ECHO -------------------------------------------------------------------------------
choice /c yn /m "Create another setup partition? "
SET ERRORTEMP=!ERRORLEVEL!
IF !ERRORTEMP! NEQ 1 (GOTO :QUIT)
:Set multiboot flag and stop winre from moving to system partition in 2nd setup
SET MULTIBOOT=1
SET WINRE=0
:Of course go back to the Partition creation area for the next install
GOTO :PARTITIONCREATION

:QUIT
:Your standard Thank you and goodbye screen
CLS
ECHO ===============================================================================
ECHO.                  DISKPART/APPLY IMAGE SCRIPT FINISHED:
ECHO -------------------------------------------------------------------------------
ECHO.            SYSTEM WILL AUTOMATATICALLY RESTART IN 10 SECONDS
ECHO ===============================================================================
choice /c rs /t 10 /d r /n /m "Press R to Restart or S to Shutdown: "
IF !ERRORLEVEL! EQU 1 WPEUTIL reboot
WPEUTIL shutdown
Echo Script failed to restart automatically.
Echo You need to restart your system manually.
pause
:EOF