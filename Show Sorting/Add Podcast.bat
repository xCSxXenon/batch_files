@echo off
setlocal & pushd .
CLS
setlocal enabledelayedexpansion

:GetNewShowName
set /p "newShowName=Enter show name: "
IF /I "%newShowName%"=="" goto ZeroLengthError

:CreateRegistryKey
REG ADD "HKCR\*\shell\Rename Episodically\shell\%newShowName%\command" /t REG_EXPAND_SZ
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /v LastKey /t REG_SZ /d "HKCR\*\shell\Rename Episodically\shell\%newShowName%\command" /f
set "defaultValue=cmd /c ""%OneDrive%\PC\Batch Files\Show Sorting\Episode Rename and Sort.bat" "%%1" "Podcasts" "%newShowName%"""
echo %defaultValue% | clip.exe
start "" regedit.exe
goto Quit

:ZeroLengthError
CLS
echo.
echo Empty name specified.
pause
cls
goto GetNewShowName

:Quit
exit