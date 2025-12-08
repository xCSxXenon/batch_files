A collection of batch scripts I wrote to automate and simplify my workflows. Written and maintained by me unless specified otherwise.

  \
"[Show Sorting](./Show%20Sorting/)" contains scripts I use for renaming and sorting episodic-style releases from independent creators.

"[USB Setup](./USB%20Setup/)" contains scripts for formatting external storage devices.

"[7zip, NanaZip, LibreOffice, VLC Installer.bat](./7zip,%20NanaZip,%20LibreOffice,%20VLC%20Installer.bat)" is a standalone script that allows you to install/uninstall the listed programs. It detects Windows 10 or 11 and queues 7zip for 10 and NanaZip for 11, removes the other. Uses WinGet for installation.

"[BitLocker Decryption with Progress Bar.bat](BitLocker%20Decryption%20with%20Progress%20Bar.bat)" makes it easy to glance at a screen to check decryption progress without having to move across a room. It asks for a volume letter, decrypts it while showing a big yellow progress bar, then displays a green success message when finished.

"[File Selector Template.bat](./File%20Selector%20Template.bat)" opens a file browsing window so you can select a file. It then displays some details about the selected file. Useful for selecting a file for processing graphically instead of CLI. Main functional code found [here](https://stackoverflow.com/questions/15885132/file-folder-chooser-dialog-from-a-windows-batch-script). Output/formatting by me.

"[Find IPv4.bat](./Find%20IPv4.bat)" finds internal/LAN ipv4 addresses present in the system.

"[FreeFileSync JSON Parser.bat](./FreeFileSync%20JSON%20Parser.bat)" takes a [FreeFileSync](https://freefilesync.org) batch configuration as an argument and parses its JSON results natively in CMD, plus a temporary external file. Official documentation uses PowerShell but I prefer CMD for its speed and lightweight-ness. It was also stated that "Windows batch scripts (.cmd/.bat) cannot parse JSON" and I am simply too stubborn not to look for a workaround. "-h" displays usage information.

"[Get Drive Letter From Volume Name.bat](Get%20Drive%20Letter%20From%20Volume%20Name.bat)" takes a volume name as argument and echos its drive letter. Code included and used in
"Get OEM Key.bat" displays the OEM Windows activation key embedded in the ACPI of the system. Usually nothing for custom builds, but super valuable for recovering keys on pre-builts and laptops.

"[Lock BitLocked Volume.bat](./Lock%20BitLocked%20Volume.bat)".

"[Lock BitLocked Volume.bat](Lock%20BitLocked%20Volume.bat)" takes a volume name as a argument and locks it. I use it to leave a process running and have it lock when finished.

"[Swap Drive Letters.bat](./Swap%20Drive%20Letters.bat)" takes two volume letters from the user and swaps them. Can also be used on a single volume by selecting a free letter for one of the prompts, simply changing the letter instead of swapping with another volume.