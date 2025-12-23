@echo off

IF "%~1"=="" goto PrintHelp
IF "%~1"=="-h" goto PrintHelp
IF "%~1"=="-a" goto AddFile
IF "%~1"=="-c" goto Commit
IF "%~1"=="-pl" goto Pull
IF "%~1"=="-ps" goto Push
IF "%~1"=="-s" goto Status


:PrintHelp
echo Usage: githelper.bat [-h ^| -a ^<file/dir^> ^| -c ^<message^> ^| -pl ^| -ps]
echo.
echo             -h    Displays this help text
echo             -a    Adds/stages file or directory
echo             -c    Commits staged files with ^<message^>
echo             -pl   Pull from origin main
echo             -ps   Pushes to origin main
echo             -s    Displays Git status
goto Quit

:AddFile
IF "%~2"=="" (echo No file/directory provided) else (git add "%~2")
goto Quit

:Commit
IF "%~2"=="" (echo No message provided) else (git commit -m "%~2")
goto Quit

:Pull
git pull
goto Quit

:Push
git push origin main
goto Quit

:Status
git status
goto Quit

:Quit
exit /b