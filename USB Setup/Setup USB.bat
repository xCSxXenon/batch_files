@echo off
set "removeDriveEXELocation=%OneDrive%\PC\Batch Files\USB Setup\RemoveDrive.exe"

:GetVolumeLetter
REM Get drive letter of flash drive
echo list vol | diskpart
echo What is the drive letter of your USB?
set /p usbLetter=

REM Checks drive letter against drives that shouldn't be formatted
IF %usbLetter%==c goto ProtectedVolumeLetter
IF %usbLetter%==d goto ProtectedVolumeLetter

REM Get name to use for flash drive label
set /p "usbLabel=Enter name for USB: "

REM Format selected drive letter as exFAT, quickly, force dismount, name it "Temp", than cange label to "Flash Drive"
REM Format command doesn't support spaces. 11 characters is the max unless using autorun file we create below
format %usbLetter%: /FS:exFAT /Q /X /V:Temp /y
label %usbLetter%: Flash Drive

REM Switch working directory to now formatted flash drive. Copy icon and autorun files to flash drive
%usbLetter%:
xcopy /Q /Y "%OneDrive%\PC\Batch Files\USB Setup\icon.ico" ".\"
xcopy /Q /Y "%OneDrive%\PC\Batch Files\USB Setup\autorun.inf" ".\"

REM Append desired label to the autorun file and make everything hidden
echo Label=%usbLabel% >> ".\autorun.inf"
attrib +H ".\autorun.inf"
attrib +H ".\icon.ico"
CHOICE /c yn /d n /t 30 /n /m "Do you want to eject? [Y/N]"
if %errorlevel%==1 goto EjectVolume
exit

:EjectVolume
REM Change working directory to release lock on volume, eject the flash drive, repeat if not successful
C:
"%removeDriveEXELocation%" %usbLetter%: -L
exit

:ProtectedVolumeLetter
echo Invalid letter
goto GetVolumeLetter
