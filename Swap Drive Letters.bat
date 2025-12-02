@echo off
set name=%~n0%~x0

:check
IF "%~0" == "%TEMP%\%name%" goto start
del /f "%TEMP%\%name%" 1> NUL 2> NUL
copy %0 "%TEMP%\" 1> NUL 2> NUL
call "%TEMP%\%name%"
exit

:start
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 

:getPrivileges 
if '%1'=='ELEV' (shift & goto gotPrivileges)  

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B 

:gotPrivileges 
::::::::::::::::::::::::::::
::START
::::::::::::::::::::::::::::
setlocal & pushd .

set tempLetter=abcdefghijklmnopqrstuvwxyz
:FindAvailableLetter
IF "%tempLetter%"=="" set "errorMessage=No free letter available for swap" & goto Error
IF NOT EXIST %tempLetter:~0,1%:\ (
    set tempLetter=%tempLetter:~0,1%
) else (
    set tempLetter=%tempLetter:~1%
    goto FindAvailableLetter
)

:GetDriveLetters
set drive1=
set drive2=
cls
echo list vol | diskpart
echo.
set /p "drive1=Select first letter: "
IF "%drive1%"=="" set "errorMessage=Drive letter missing" & goto Error
IF "%drive1:~1%" NEQ "" set "errorMessage=More than one character entered" & goto Error
IF "%drive1%"=="c" set "errorMessage=OS drive (C:) selected" & goto Error
echo.
set /p "drive2=Select second letter: "
IF "%drive2%"=="" set "errorMessage=Drive letter missing" & goto Error
IF "%drive2:~1%" NEQ "" set "errorMessage=More than one character entered" & goto Error
IF "%drive2%==c" set "errorMessage=OS drive (C:) selected" & goto Error
IF "%drive1%"=="%drive2%" set "errorMessage=Duplicate letters entered" & goto Error
echo.
(echo sel vol %drive1%
echo remove
echo assign letter=%tempLetter%
echo sel vol %drive2%
echo remove
echo assign letter=%drive1%
echo sel vol %tempLetter%
echo remove
echo assign letter=%drive2%
) | diskpart
exit

:Error
cls
echo.
echo Error: %errorMessage%
pause
goto GetDriveLetters