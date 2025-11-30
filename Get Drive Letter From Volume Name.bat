@echo off
setlocal enabledelayedexpansion

REM A script that takes an input volume name and returns its drive letter.
REM No warranty expressed or implied, use at your own risk.

REM Usage: Call script with a volume name as a quoted parameter. Ex: GetDriveLetterFromVolumeName.bat "USB drive"
REM Add a second paramter "detailed" if you want more than just a letter returned.

REM LIMITATIONS
REM This only searches using the first 11 characters. If multiple volume names share the first 11 characters, this is unreliable.
REM If the search string contains extra spaces at the end, or vice versa, it still matches. Feature?
REM Only works on local storage.

REM Diskpart only displays the first 11 characters, so pad and truncate for easier comparison later
set volumeName=%~1
set limitedVolumeName=%volumeName%           
set limitedVolumeName=%limitedVolumeName:~0,11%

set detailed=false
IF /I "%~2"=="detailed" set detailed=true

REM Save output of DiskPart 'list vol' in file for parsing.
REM Parse file, looking for volume name. Keep first 30 characters to confirm volume name.
REM This prevents false positives in cases where a volume name is a possible value for another column.
set found=false
echo list vol | diskpart > volumes.txt
for /f "delims=" %%a in ('find /I "   %limitedVolumeName%  " volumes.txt') do (
  set volumeLine=%%a
  set volumeLine=!volumeLine:~0,30!
  IF /I "!volumeLine:~-11!"=="%limitedVolumeName%" (set found=true)
)

IF %found%==false goto volumeNotFound
REM There is an edge case if you search for "volumes.txt" but it isn't an existing volume.
REM %found% will be true, because 'findstr' also returns the file name for some reason.
REM The below conditional checks for this.
IF "%volumeLine:~0,10%"=="----------" goto volumeNotFound

REM Get the volume letter and check if it is empty
set volumeLetter=%volumeLine:~15,1%
IF "%volumeLetter%"==" " goto noLetterAssigned

REM Display result
IF %detailed%==true (
  echo "%volumeName%" has assigned letter: %volumeLetter%
) else (
  echo %volumeLetter%
)
goto end

:noLetterAssigned
echo.
echo Volume name found but it has no assigned letter.
echo It may be mounted using a mountpoint?
goto end

:volumeNotFound
echo.
echo Volume name not found. Search is not case-sensitive, but check for typos
goto end

:end
del volumes.txt