A collection of batch scripts I wrote to automate and simplify my workflows. Written and maintained by me unless specified otherwise.

&nbsp; 
"[Show Sorting](./Show%20Sorting/)" contains scripts I use for renaming and sorting episodic-style releases from independent creators.

"[USB Setup](./USB%20Setup/)" contains scripts for formatting external storage devices.

"7zip, NanaZip, LibreOffice, VLC Installer.bat" is a standalone script that allows you to install/uninstall the listed programs. It detects Windows 10 or 11 and queues 7zip for 10 and NanaZip for 11. Uses WinGet for installation.

"BitLocker Decryption with Progress Bar.bat" is just for convenience. It asks for a volume letter and decrypts it while showing a big yellow progress bar. Can't clone BitLocked drives in an efficient way, IYKYK. This makes it easy to glance at a screen to check progress without having to move across a room or building.

"[File Selector Template.bat](./File%20Selector%20Template.bat)" opens a file browsing window so you can select a file. It then displays some details about the selected file. Useful for selecting a file for processing graphically instead of CLI. Main functional code found [here](https://stackoverflow.com/questions/15885132/file-folder-chooser-dialog-from-a-windows-batch-script). Output/formatting by me.

"Find IPv4.bat" finds ipv4 addresses present in the system.

"[Get Drive Letter From Volume Name.bat](Get%20Drive%20Letter%20From%20Volume%20Name.bat)" takes a volume name as argument and echos its drive letter. Code included and used in
"Get OEM Key.bat" displays the OEM Windows activation key embedded in the ACPI of the system. Usually nothing for custom builds, but super valuable for recovering keys on pre-builts and laptops.

"[Lock BitLocked Volume.bat](./Lock%20BitLocked%20Volume.bat)".

"[Lock BitLocked Volume.bat](Lock%20BitLocked%20Volume.bat)" takes a volume name as a argument and locks it. I use it to leave a process running and have it lock when finished.

"Swap Drive Letters.bat" takes two volume letters from the user and swaps them. Easier than diskpart or Disk Management.

