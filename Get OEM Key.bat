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
cls

FOR /F "eol=O delims=" %%a in ('wmic path softwarelicensingservice get oa3xoriginalproductkey') do (FOR /f "delims=" %%b in ("%%a") do IF NOT "%%~nb"=="                        " (set key=%%b && goto Found) ELSE (goto NoKey))
:Found
set key=%key:~0,29%
echo %key% | clip
color 02
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo          Key found:  %key%
echo          It has been copied to your clipboard
echo.
echo.
echo.
echo.
echo.
echo.
CHOICE /T 2 /C y /M "Opening Activation page..." /N /D y
slui 3
exit

:NoKey
color 04
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo "    __    __   ______         __    __  ________  __      __       
echo "   /  \  /  | /      \       /  |  /  |/        |/  \    /  |
echo "   $$  \ $$ |/$$$$$$  |      $$ | /$$/ $$$$$$$$/ $$  \  /$$/ 
echo "   $$$  \$$ |$$ |  $$ |      $$ |/$$/  $$ |__     $$  \/$$/  
echo "   $$$$  $$ |$$ |  $$ |      $$  $$<   $$    |     $$  $$/   
echo "   $$ $$ $$ |$$ |  $$ |      $$$$$  \  $$$$$/       $$$$/    
echo "   $$ |$$$$ |$$ \__$$ |      $$ |$$  \ $$ |_____     $$ |    
echo "   $$ | $$$ |$$    $$/       $$ | $$  |$$       |    $$ |    
echo "   $$/   $$/  $$$$$$/        $$/   $$/ $$$$$$$$/     $$/     
echo.
echo "    ________  ______   __    __  __    __  _______  
echo "   /        |/      \ /  |  /  |/  \  /  |/       \ 
echo "   $$$$$$$$//$$$$$$  |$$ |  $$ |$$  \ $$ |$$$$$$$  |
echo "   $$ |__   $$ |  $$ |$$ |  $$ |$$$  \$$ |$$ |  $$ |
echo "   $$    |  $$ |  $$ |$$ |  $$ |$$$$  $$ |$$ |  $$ |
echo "   $$$$$/   $$ |  $$ |$$ |  $$ |$$ $$ $$ |$$ |  $$ |
echo "   $$ |     $$ \__$$ |$$ \__$$ |$$ |$$$$ |$$ |__$$ |
echo "   $$ |     $$    $$/ $$    $$/ $$ | $$$ |$$    $$/ 
echo "   $$/       $$$$$$/   $$$$$$/  $$/   $$/ $$$$$$$/
echo.
echo.
echo.
echo.
echo.
echo.
pause