Win 11 Boot And Upgrade FiX KiT v6.1f

Crappy Tools By Enthousiast @MDL modded by bloodrain @MDL

Support: https://forums.mydigitallife.net/threads/win-11-boot-and-upgrade-fix-kit.83724/

Do not ask for support on this modded version on MDL! Create an issue on GitHub:

https://github.com/EntropyKitty/win-11-boot-and-upgrade-fix-kit-mod

- The tool provides multiple fixes (inclusing the option to install 11 on a legacy-Bios system).
- You can select AIO 1 or 2 to choose the recommended combinations.
- If Fix 3 is chosen alone, it will be applied solely for current OS.
- If Fix 6 is chosen, it will be applied solely.
- Extras options 6-7-8-9 can be enabled (recommended) or disabled regardless fixes.

=================================== Fixes ====================================

* AIO 1 : UFWS + setup.cfg (2022/2025)

Pros:
- The recommended option.
- Circumvents all Win 11 minimum requirements (CPU-RAM-Disksize-TPM-Secureboot/legacy-Bios).
- Replaces ISO & boot.wim "inf\setup.cfg" with one from Server 2022/2025 ISO.
- Works for both, modern setup and legacy setup.
- Works for boot and upgrade scenarios.
- This fix cannot be applied to split install.swm files.

Cons:
- It does not work on hardware that isn't supported by Windows Server.

Important:
This lets Windows think it is installing server, that's why setup will show "Server" in the title bar...

============

* AIO 2a: boot.wim Registry + winsetup.dll

Pros:
- Bypass CPU-Disksize-RAM-TPM-Secureboot/Legacy-Bios checks for new setup (Win 11 24H2+).
- Bypass RAM-TPM-Secureboot/Legacy-Bios checks for legacy setup (Win 11 all).
- Use the standard Win 11 setup for clean installs on devices without:
Secure Boot, TPM 2.0 & RAM < 8GB.
- Circumvents "TPM 2.0 is required" error when (inplace) upgrading.
- Enables to install on Legacy BIOS^/MBR only systems.
- Works for hardware that isn't supported by Windows Server.

Cons:
- To work for live upgrades for Win 11 24H2+, it needs option "AIO 2b" to run on the OS which would be upgraded (a small standalone script will be copied to the ISO).

============

* AIO 2b: Current OS Registry

Pros:
- Circumvents all minimum requirements for live upgrades (Win 11 24H2+).
- It's not needed if the Win 11 ISO fixed with option "AIO 2a" is ran on the same OS which would be upgraded.

Cons:
- Works for Win 11 24H2+ only.
- Might not continue to work in future.

============

* Use a Win 10 ISO setup files
 
- Puts the Win 11 install.wim/esd in a Win 10 ISO.
- You must Provide a Win 10 ISO in the "Source_ISO\W10\" Folder.
- Works for clean installs from boot, using the standard W10 setup.

=================================== Extras ===================================

[ 6 ] Replace ISO appraiserres.dll

- Replaces Win 11 "appraiserres.dll" with one from Win 10 15063 ISO.
- You can insert your own different file in the Files folder.
- The original Win 11 ISO file will be renamed to appraiserres.dll.bak

============

[ 7 ] Integrate Diskpart & Apply Image script

- Adds Murphy78 Diskpart and Apply Image Script 1.3.1 To Boot.wim
- Works as alternative for clean installs.

============

[ 8 ] Add the generic EI.CFG file

- A generic EI.CFG file will be copied to the sources folder.
- If exists, the original file will be renamed to EI.CFG.Ori

============

[ 9 ] Optimize boot.wim

- Export and rebuild boot.wim to discard void files and reduce size.

[ A ] Add 22621 autorun.dll to boot.wim

- to autostart legacy setup and enable to select the desired SKU on systems with a MSDM for a specific SKU

[ B ] Disable automatic BitLocker encryption during Windows Setup, fix copied from Rufus

- Allows you to not use BitLocker or encrypt yourself later, allowing you to save your BitLocker keys for use with a local account

[ D ] Add drivers to boot.wim and install.wim

- Add drivers from Drivers folder to boot.wim and install.wim, will automatically convert .esd, .wim, and .swm files and convert back as needed

[ M ] Disable requirement for Microsoft Account during setup

- Adds BypassNRO registry key to OOBE, fix copied from Rufus

[ O ] Copy OfflineInsiderEnroll script to enable Windows Insider ISOs without Microsoft Account

- Copies OfflineInsiderEnroll.cmd to the root of the ISO, enables use of Windows Insider ISOs without Microsoft Account

[ P ] Add custom product key to PID.txt

- Allows specifying custom product key for Setup to use.

[ S ] Split install.wim to 4GB for FAT32 USB sticks

- Allows copying ISO files directly to a FAT32 USB stick for UEFI booting and creating a USB stick that uses FAT32 (not UEFI:NTFS, Secure Boot compatible) with Rufus

[ W ] Disable Windows Platform Binary Table software auto installation

- Disabled automatic installation of software embedded in the Windows Platform Binary Table, such as ASUS Armoury Crate and McAfee Antivirus. (These are only two known examples) This can be considered an annoyance and security risk by some.

=================================== Bonus =====================================

# The following are manual options, which can be disabled only by editing the script.

# Add Upgrade_Fail_Fix.cmd:
- The script enable flightsigning which is required for Windows Insider channels.
- Can be used when public release (all Win 7/8/10) is upgraded to Insider channel release ISO.
- After executing the script and rebooting, you can simply run standard setup.
- The option is OFF be default because it's not needed for recent 2024+ builds

==============================================================================

Diskpart and Apply Image usage instructions:

After selecting the desired keyboard language press "SHIFT+F10" to open commandprompt and type "menu", press "Y" and next "F" and "Y" again.

The options for recovery options are removed from the script by @murphy78 (no longer supported on 10/11).

Video: https://i.imgur.com/1uDnjKr.gif

Official (support) thread: https://forums.mydigitallife.net/threads/win-11-boot-and-upgrade-fix-kit-v1-5.83724/

Do not ask for support on this modded version on MDL! Create an issue on GitHub:

https://github.com/EntropyKitty/win-11-boot-and-upgrade-fix-kit-mod

====================================================================

Changelog:

6.1f
Added placeholders so GitHub wouldn't remove empty folders
Added option to disable software auto-installation from Windows Platform Binary Table
Added option to quit (removes lock file cleanly) from the main menu

6.0f

Upgraded 7z to 24.09
Upgraded wimlib to 1.14.4
Added logging
Added lockfile so the script wouldn't run more than once from the same directory
Added automatic unmounting of images mounted in the Mount directory upon startup
Added oscdimg binary for x64
Added binaries for arm64 (though what purpose this serves, I have no idea)
Added automated conversion and reconversion for swm and esd file based ISOs
Added option to disable BitLocker
Added option to add drivers to install.wim and boot.wim
Added option to disable requirement for Microsoft account during setup
Added OfflineInsiderEnroll.cmd for Windows Insider ISOs without a Microsoft Account
Added option to add custom product key to PID.txt
Added option to split wim to 4GB for FAT32 USB sticks

5.1f

Added code to skip the adding of the 22621 autorun.dll when the source iso is not 26100 or later.
Did some rewording to make sure people see that adding the 22621 autorun.dll is only meant for 26100 or later builds.

5.1

Added the option to add 22621 autorun.dll to boot.wim to autostart legacy setup and enable to select the desired SKU on systems with a MSDM for a specific SKU

v4.0

- Removed the combining of the UFWS with the Boot.wim registry fixes.
- Added the patching "winsetup.dll in boot.wim" method (thanks to @aveyo for the original snippet and @abbodi1406 for translating it to my level of coding :)
- Added the option to copy a $OEM$ folder to the ISO (put $OEM$ folder inside the project OEM folder).

v3.0

- Unified the old boot.wim registry modification\appraiserres.dll replacement method with the UFWS (WINDOWS/INSTALLATIONTYPE=Server) method.
- Updated the wimlib-imagex and 7zip files to the latest available
- Updated the code to be able to handle spacings in the folder path/name (code suggestion by @rpo)
- You can insert your own desired win 10 appraiserres.dll file in the "Files" folder, the script will show what version it is (by default the one from a 15063 ISO is provided).
- Made the integration of the Diskpart & Apply Image script (v1.3.1) by @murphy78 optional by editing the script settings:

SET "DPaA=1" < This sets the script to integrate the Diskpart & Apply Image script (v1.3.1), when set to "0" it won't integrate it.

v2.2

Replaced the UFWS cmd by UFWS v1.4, now modifying the index info on install.wim/esd to circumvent the win 11 minimum system requirements when clean installing or upgrading.
UFWS enables you to do ISO upgrades without the need for disconnecting from internet.
The tool now uses only one folder for the used files, thanks to @W_fantasma at MDL.
Added an "Upgrade_Fail_Fix.cmd to the root of the ISO, meant for when upgrading has failed.
Also put in direct CMD settings for adding ei.cfg and boot.wim optimization.
Replaced the date assessment for ISO fix date by code suggestion by @RPO at MDL
Added 2 new settings on the cmd file directly:

SET "EI_CFG_ADD=1" <--- This sets the script to add the generic ei.cfg (if already exists, the existing one will be renamed to "EI.CFG.Ori"), when set to "0" the generic ei.cfg will not be copied, existing ones will remain on the ISO.
SET "Boot_WIM_Opt=1" <--- This sets the script to run the optimize (rebuild) command for boot.wim, when set to "0" it won't.

v2.1

Fixed the wimic stuff by @abbodi1406 at MDL
Added UFWS v1.3 (https://github.com/uwuowouwu420/ufws)

v2.0

Added the 64GB minimum disksize check bypass
Changed the code to use the original filename with "FiXED_date" addition (requested by @antonio8909 and used code offered by @rpo )
Added the ei.cfg copy function to option 2 too
Added some more info about what the fixes enable to do (suggested by @ch100 )

v1.9

Removed the need for mounting boot.wim, speeding up the progress

v1.8

Added the latest Diskpart & Apply Image v1.3.1 (@murphy78 removed the options for recovery, they are no longer supported by MSFT)

v1.7

Fixed the problems with running the tool from a file path containing spacings (help from @murphy78)

v1.6

Updated wimlib files
Added Bypassramcheck to option 2