@echo off
pushd "%~dp0/.."
echo.
set /p "newScriptName=Enter script name: "
echo @echo off> "%newScriptName%.bat"
START "" notepad.exe "%newScriptName%.bat"
popd
exit /b