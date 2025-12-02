@echo off
setlocal enabledelayedexpansion
cls

set filter=enabled
set updatingStatus=false
set "filteredKeyPath=HKCR\*\shell\Rename Episodically\shell"
set "unfilteredKeyPath=HKCR\*\Disabled Shows"
set charactersToStrip=52

:GetListOfShows
set iter=1
for /F "delims=" %%a in ('reg query "%filteredKeyPath%"') do (
    set "entryName=%%a"
    set "entryName=!entryName:~%charactersToStrip%!"
    set "show!iter!=!entryName!"
    set /a iter=!iter!+1
)
set /a numberOfEntries=%iter%-1
IF %updatingStatus%==false echo.
set updatingStatus=false

:DisplayList
echo.
echo Currently %filter% shows:
for /L %%a in (1,1,%numberOfEntries%) do (
    echo %%a: !show%%a!
)

:GetSelection
echo.
set selection=0
echo Enter 't' to toggle enable/disable or 'q' to quit.
IF "%filter%"=="enabled" (set /p "selection=Enter number to disable: ") else (set /p "selection=Enter number to enable: ")
IF %selection% EQU q cls & goto :EOF
IF %selection% EQU t cls & goto ToggleEnableDisable
IF %selection% LSS 1 cls & echo Invalid number & goto DisplayList
IF %selection% GTR %numberOfEntries% cls & echo Invalid number & goto DisplayList
REG COPY "%filteredKeyPath%\!show%selection%!" "%unfilteredKeyPath%\!show%selection%!" /s /f
REG DELETE "%filteredKeyPath%\!show%selection%!" /f
cls
IF %filter%==enabled (
    echo Disabled "!show%selection%!" successfully!
) else (
    echo Enabled "!show%selection%!" successfully!
)
set updatingStatus=true
goto GetListOfShows


:ToggleEnableDisable
IF %filter%==enabled (
    set filter=disabled
    set charactersToStrip=35
) else (
    set filter=enabled
    set charactersToStrip=52
)
set "swapPath=%filteredKeyPath%"
set "filteredKeyPath=%unfilteredKeyPath%"
set "unfilteredKeyPath=%swapPath%"
set swapPath=
cls
goto GetListOfShows