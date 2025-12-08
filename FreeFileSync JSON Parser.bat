@echo off
setlocal enabledelayedexpansion

:UserDefinedSettings
set ffsEXE="C:\Program Files\FreeFileSync\FreeFileSync.exe"
set cleanupWorkingDirectory=true
set expandDateTime=false
set formatTime=false
goto VerifyFFSConfig

:VerifyFFSConfig
REM Verifies that a path to a FFS config was provided and that it exists.
IF "%~1"=="" goto PrintHelp
IF "%~1"=="-h" goto PrintHelp
IF "%~1"=="-d" goto DestroyAllWorkingDirectories
IF NOT EXIST "%~1" set "errorMessage=Provided configuration could not be found." & goto Error
IF "%~x1" NEQ ".ffs_batch" set "errorMessage=Provided configuration is not a .ffs_batch file." & goto Error
set ffsConfigFile="%~1"
SHIFT
goto CheckParameters

:CheckParameters
REM Check for provided CLI parameters
IF "%~1"=="" goto CreateWorkingDirectory
IF "%~1"=="-c" set cleanupWorkingDirectory=false
IF "%~1"=="-e" set expandDateTime=true
IF "%~1"=="-f" set formatTime=true
IF "%~1"=="-h" goto PrintHelp
SHIFT
goto CheckParameters

:Error
echo.
echo %errorMessage%
goto Quit

:PrintHelp
echo.
echo Usage: %0 ^<path^> [-c] [-e [-f]] ^| -d
echo.
echo             -h    Displays this help text
echo             -c    Don't delete temporary working directory
echo             -e    Expand "startTime" into its date and time components
echo             -f    Format time to remove offset and append AM/PM. Only works with -e
echo             -d    Delete all previous temporary working directories
echo.
goto Quit

:DestroyAllWorkingDirectories
rd /s /q "%TEMP%\FreeFileSyncJSONParsing" 1>NUL 2>NUL
echo Deleted "%TEMP%\FreeFileSyncJSONParsing"
goto Quit

:CreateWorkingDirectory
REM Creates unique working directory in %TEMP% to avoid race conditions
set parsingSubdirectory=%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%
mkdir %TEMP%\FreeFileSyncJSONParsing\%parsingSubdirectory%
pushd %TEMP%\FreeFileSyncJSONParsing\%parsingSubdirectory%
goto RunAndProcessJSON

:RunAndProcessJSON
REM Runs FFS with the config and stores the JSON output in a file
%ffsEXE% %ffsConfigFile% > jsonResults.log

REM Read file, ignoring brackets at beginning and end, format and store values in variables named by each stat
for /f "tokens=1,* delims=:" %%a in (jsonResults.log) do (
    IF "%%a" NEQ "{" (
        IF "%%a" NEQ "}" (
            set "statName=%%a"
            set statName=!statName: =!
            set statName=!statName:"=!
            set "statValue=%%b"
            set statValue=!statValue:~1!
            set statValue=!statValue:"=!
            set statValue=!statValue:,=!
            set ffs_!statName!=!statValue!
        )
    ) 
)
popd
goto CleanupWorkingDirectory

:CleanupWorkingDirectory
REM Remove working directory, if requested
IF "%cleanupWorkingDirectory%"=="false" goto CheckIfEmpty
rd /s /q "%TEMP%\FreeFileSyncJSONParsing\%parsingSubdirectory%"
goto CheckIfEmpty

:CheckIfEmpty
REM Remove parent directory, if empty
dir /b "%TEMP%\FreeFileSyncJSONParsing\" | findstr /R "." >NUL && goto ExpandTimestamp
rd /s /q "%TEMP%\FreeFileSyncJSONParsing"
goto ExpandTimestamp

:ExpandTimestamp
REM Split date and time inside %ffs_startTime% into separate %ffs_startDate% and %ffs_startTime% variables, if requested
IF "%expandDateTime%"=="false" goto DisplayResults
FOR /f "tokens=1,2 delims=T" %%a in ("%ffs_startTime%") do (
    set ffs_startDate=%%a
    set ffs_startTime=%%b
)
goto CleanupTime

:CleanupTime
REM Remove time offset, format for 12-hour format, and add am/pm, if requested
IF "%formatTime%"=="false" goto DisplayResults
set AMorPM=AM
set ffs_startTime=%ffs_startTime:~0,8%
IF %ffs_startTime:~0,1% EQU 0 (
    set /A startHour=%ffs_startTime:~1,1%
) ELSE (
    set /A startHour=%ffs_startTime:~0,2%
)
IF %startHour% EQU 12 (
    set AMorPM=PM
) ELSE IF %startHour% EQU 0 (
    set startHour=12
) ELSE IF %startHour% GTR 12 (
    set /A startHour-=12
    set AMorPM=PM
)
set ffs_startTime=!startHour!%ffs_startTime:~2,6%
set ffs_startTime=%ffs_startTime% %AMorPM%
goto DisplayResults

:DisplayResults
echo syncResult:     %ffs_syncResult%
IF "%expandDateTime%"=="true" (echo startDate:      %ffs_startDate%) else (echo startTime:      %ffs_startTime%)
IF "%expandDateTime%"=="true" echo startTime:      %ffs_startTime%
echo totalTimeSec:   %ffs_totalTimeSec%
echo errors:         %ffs_errors%
echo warnings:       %ffs_warnings%
echo totalItems:     %ffs_totalItems%
echo totalBytes:     %ffs_totalBytes%
echo processedItems: %ffs_processedItems%
echo processedBytes: %ffs_processedBytes%
echo logFile:        "%ffs_logFile%"

:Quit
exit /b