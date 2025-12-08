@echo off
setlocal enabledelayedexpansion

:UserDefinedSettings
set ffsEXE="C:\Program Files\FreeFileSync\FreeFileSync.exe"
set ffsConfigFile="D:\OneDrive\FreeFileSync Configurations\ISOs.ffs_batch"
set cleanup=true
set expandDateTime=true
set formatTime=true
goto CheckOverrides

:CheckOverrides
REM Check for provided CLI parameters
goto CreateWorkingDirectory


:CreateWorkingDirectory
REM Creates unique working directory in %TEMP% to avoid race conditions
set parsingTimestamp=%date:~4%%time:~0,8%
set parsingTimestamp=%parsingTimestamp:/=%
set parsingTimestamp=%parsingTimestamp::=%
mkdir %TEMP%\FreeFileSyncJSONParsing\%parsingTimestamp%
pushd %TEMP%\FreeFileSyncJSONParsing\%parsingTimestamp%
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
            set statValue=!statValue: =!
            set statValue=!statValue:,=!
            set !statName!=!statValue!
        )
    ) 
)
popd
goto CleanupWorkingDirectory

:CleanupWorkingDirectory
REM Remove working directory, if requested
IF "%cleanup%"=="false" goto NotEmpty
rd /s /q "%TEMP%\FreeFileSyncJSONParsing\%parsingTimestamp%"
goto CheckIfEmpty

:CheckIfEmpty
REM Remove parent directory, if empty
dir /b "%TEMP%\FreeFileSyncJSONParsing\" | findstr /R "." && goto NotEmpty
rd /s /q "%TEMP%\FreeFileSyncJSONParsing"
goto ExpandTimestamp

:NotEmpty
goto ExpandTimestamp

:ExpandTimestamp
REM Split date and time inside %startTime% into separate %startDate% and %startTime% variables, if requested
IF "%expandDateTime%"=="false" goto DisplayResults
FOR /f "tokens=1,2 delims=T" %%a in (%startTime%) do (
    set startDate=%%a
    set startTime=%%b
)
goto CleanupTime

:CleanupTime
REM Remove time offset, format for 12-hour format, and add am/pm, if requested
IF "%formatTime%"=="false" goto DisplayResults
set AMorPM=AM
IF %startTime:~0,2% GTR 12 set /A startHour=%startTime:~0,2%-12 & set AMorPM=pm
set startTime=%startHour%%startTime:~2,6% %AMorPM%
goto DisplayResults

:DisplayResults
echo syncResult: %syncResult%
IF "%expandDateTime%"=="true" (echo startDate: %startDate%) else (echo startTime: %startTime%)
IF "%expandDateTime%"=="true" echo startTime: %startTime%
echo totalTimeSec: %totalTimeSec%
echo errors: %errors%
echo warnings: %warnings%
echo totalItems: %totalItems%
echo totalBytes: %totalBytes%
echo processedItems: %processedItems%
echo processedBytes: %processedBytes%
echo logFile: %logFile%

:Quit
popd
exit /b