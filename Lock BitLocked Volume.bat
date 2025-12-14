@echo off
setlocal enabledelayedexpansion
cd /d %TEMP%

REM TODO Make a displayable helptext

REM User configurable settings
REM TODO: Make these configurable via parameters
set lockTimeoutSeconds=10
set lockRetryCount=2

REM A script that takes an input volume name and locks it.
REM Usage: Call script with a volume name as a quoted parameter. Ex: GetDriveLetterFromVolumeName.bat "USB drive"

REM LIMITATIONS
REM This only searches using the first 11 characters. If multiple volume names share the first 11 characters, this is unreliable.
REM If the search string contains extra spaces at the end, or vice versa, it still matches. Feature? Only works on local storage.

REM Setup tracking variables, do not edit.
set lockAttemptCount=1
set /A lockAttemptMax=%lockRetryCount%+1

REM Diskpart only displays the first 11 characters, so pad and truncate for easier comparison later
set volumeName=%~1
set limitedVolumeName=%volumeName%           
set limitedVolumeName=%limitedVolumeName:~0,11%

REM Save output of DiskPart 'list vol' in a file and parses it looking for volume name. Keep first 30 characters to confirm
REM volume name. This prevents false positives in cases where a volume name is a possible value for another column.
set found=false
echo list vol | diskpart > volumes.txt
for /f "delims=" %%a in ('find /I "   %limitedVolumeName%  " volumes.txt') do (
  set volumeLine=%%a
  set volumeLine=!volumeLine:~0,30!
  IF /I "!volumeLine:~-11!"=="%limitedVolumeName%" (set found=true)
)

IF %found%==false goto VolumeNotFound
REM Edge case: If you search for "volumes.txt" but it isn't an existing volume, %found% will be true because 'findstr' also
REM returns the file name for some reason. The below conditional checks for this.
IF "%volumeLine:~0,10%"=="----------" goto VolumeNotFound

REM Get the volume letter and check if it is empty
set volumeLetter=%volumeLine:~15,1%
IF "%volumeLetter%"==" " goto NoLetterAssigned

REM Lock volume
:Lock
cls
manage-bde -lock %volumeLetter%:
IF EXIST %volumeLetter%:\ goto LockTimeout
goto Quit

:LockTimeout
cls
set lockTimeoutSecondsLeft=%lockTimeoutSeconds%
set seconds=%time:~6,2%
echo Failed to lock (%lockAttemptCount%/%lockAttemptMax%)
echo Retrying in: %lockTimeoutSecondsLeft% seconds

:CountTime
IF %seconds% == %time:~6,2% goto CountTime
cls
set seconds=%time:~6,2%
set /A lockTimeoutSecondsLeft-=1
echo Failed to lock (%lockAttemptCount%/%lockAttemptMax%)
echo Retrying in: %lockTimeoutSecondsLeft% seconds
IF %lockTimeoutSecondsLeft% GTR 0 goto CountTime
set /A lockAttemptCount+=1
IF %lockAttemptCount% GTR %lockAttemptMax% goto ForceLock
goto Lock

:ForceLock
manage-bde -lock %volumeLetter%: -ForceDismount
IF EXIST %volumeLetter%:\ goto ForceLockFailed
goto Quit

:ForceLockFailed
start "" msg * /TIME:2147483647 Failed to dismount "%~1"
goto Quit

:NoLetterAssigned
echo.
echo Volume name found but it has no assigned letter.
echo It may be mounted using a mountpoint, which isn't supported.
goto Quit

:VolumeNotFound
echo.
echo Volume name not found. Search is not case-sensitive, but check for typos
goto Quit

:Quit
del volumes.txt
exit /b