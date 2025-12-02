@echo off
set name=%~n0%~x0

IF "%~0" == "%TEMP%\%name%" goto Start
del /f "%TEMP%\%name%" 1> NUL 2> NUL
copy %0 "%TEMP%\" 1> NUL 2> NUL
call "%TEMP%\%name%"
exit

:Start
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto GotPrivileges) else ( goto GetPrivileges) 

:GetPrivileges
if '%1'=='ELEV' (shift & goto gotPrivileges)  

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B 

:GotPrivileges
::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
setlocal & pushd .
cls

REM Make sure WinGet is installed/registered
Powershell Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

set action=Install
set oppositeAction=Uninstall
set packageName=none

REM 
for /f "delims=:, tokens=1*" %%a in ('systeminfo') do (IF "%%a"=="OS Name" set "windowsVersion=%%b" & goto GotOSName)
:GotOSName
cls
set windowsVersion=%windowsVersion: =%
set windowsVersion=%windowsVersion:~16,2%
IF %windowsVersion%==10 (
    set packageName=7zip.7zip
    set displayName=7zip
    set oppositePackageName=M2Team.NanaZip
    set oppositeDisplayName=NanaZip
    goto DisplayMenu
)
IF %windowsVersion%==11 (
    set packageName=M2Team.NanaZip
    set displayName=NanaZip
    set oppositePackageName=7zip.7zip
    set oppositeDisplayName=7zip
    goto DisplayMenu
)
goto NotWindows10or11

:DisplayMenu
cls
echo =========================================
echo          Installation Menu
echo =========================================
echo [1] %action% %displayName%
echo [2] %action% VLC
echo [3] %action% LibreOffice
echo [4] %action% All
echo [q] Exit
echo [u] %oppositeAction% menu
echo =========================================
echo.
echo Enter your selection:
CHOICE /n /c 1234qu
if %errorlevel%==1 goto 17zipNanaZip
if %errorlevel%==2 goto 2Vlc
if %errorlevel%==3 goto 3LibreOffice
if %errorlevel%==4 goto 4All
if %errorlevel%==5 exit
if %errorlevel%==6 goto SwitchAction
echo Invalid selection
pause
goto DisplayMenu

:17zipNanaZip
cls
echo %action%ing %displayName%...
IF %action%==Install echo %oppositeAction%ing %oppositeDisplayName%, if present.
CALL :Winget7zipNanaZip
cls
echo.
echo %displayName% %action%ed!
IF %action%==Install echo %oppositeDisplayName% %oppositeAction%ed, if present.
pause
goto DisplayMenu

:2Vlc
cls
echo %action%ing VLC...
CALL :WingetVLC
cls
echo.
echo VLC %action%ed!
pause
goto DisplayMenu

:3LibreOffice
cls
echo %action%ing LibreOffice...
CALL :WingetLibreOffice
cls
echo.
echo LibreOffice %action%ed!
pause
goto DisplayMenu

:4All
cls
echo %action%ing 7-Zip/NanaZip, VLC, and LibreOffice...
CALL :Winget7zipNanaZip
CALL :WingetVLC
CALL :WingetLibreOffice
cls
echo.
echo 7-Zip/NanaZip, VLC, and LibreOffice %action%ed!
pause
goto DisplayMenu

:SwitchAction
set tempAction=%action%
set action=%oppositeAction%
set oppositeAction=%tempAction%
set tempAction=
goto DisplayMenu

:Winget7zipNanaZip
IF %action%==Install (
    winget %action% %packageName% --accept-source-agreements --accept-package-agreements
    winget %oppositeAction% %oppositePackageName%
) else (
    winget %action% %packageName%
)
rd /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\7-Zip" 1>NUL 2>NUL
goto :EOF

:WingetLibreOffice
IF %action%==Install (
    winget %action% TheDocumentFoundation.LibreOffice --accept-source-agreements --accept-package-agreements
) else (
    winget %action% TheDocumentFoundation.LibreOffice
)
goto :EOF

:WingetVLC
IF %action%==Install (
    winget %action% VideoLAN.VLC --accept-source-agreements --accept-package-agreements
) else (
    winget %action% VideoLAN.VLC
)
rd /s /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\VideoLAN" 1>NUL 2>NUL
del /f "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\VLC Media Player.lnk" 1>NUL 2>NUL
del /f "%PUBLIC%\Desktop\VLC media player.lnk" 1>NUL 2>NUL
goto :EOF

:NotWindows10or11
cls
echo This only works for Windows 10 and 11, and I've detected that this isn't one of those
echo Exitting...
pause
exit