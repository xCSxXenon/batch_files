@echo off
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%a in ('mshta.exe %dialog%') do set "fileName=%%~na" && set "fileExtension=%%~xa" && set "filePath=%%~da%%~pa"
cls
echo  Selected "%filePath%%fileName%%fileExtension%"
echo.
echo  Filename:         %fileName%
echo  Extension:        %fileExtension:~1%
echo  Path:             %filePath%
pause