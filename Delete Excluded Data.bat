@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ------------- CONFIG/SETUP -------------
set "freeFileSyncLocation=C:\Program Files\FreeFileSync\FreeFileSync.exe"

REM Verify that a valid configuration was provided and exists
if "%~1"=="" (
    echo Usage: %~nx0 ^<path^>
    echo            Where ^<path^> is the full path to your FFS configuration file.
    echo            Supports .ffs_gui/.ffs_batch configurations.
    echo            .ffs_batch configurations will be ===RAN AUTOMATICALLY===
    echo            .ffs_GUI configurations will be opened in the GUI.
    exit /b 1
)
if not exist "%~1" (
    echo Provided configuration file not found.
    exit /b 1
)
if "%~x1" NEQ ".ffs_gui" (
    if "%~x1" NEQ ".ffs_batch" (
        echo Provided file is not a FFS configuration file.
        exit /b
    )
)
REM Create unique temporary working directory and empty directory inside
set "tempWorkingDirectory=%DATE:~4%%TIME::=%"
set "tempWorkingDirectory=%tempWorkingDirectory:/=%"
set "tempWorkingDirectory=%tempWorkingDirectory:.=%"
set "tempWorkingDirectory=%tempWorkingDirectory: =%"
set "tempWorkingDirectory=%TEMP%\%tempWorkingDirectory%"
mkdir "%tempWorkingDirectory%\empty"
REM Parse input config for extension and file name for temp configuration file
set "inputConfiguration=%~1"
set "tempConfiguration=%tempWorkingDirectory%\deleteExcludedData_%~nx1"

REM Parse provided configuration and create new one
REM 'skip' is used to skip entire blocks in the XML data
set skip=FALSE
for /F "usebackq delims=" %%a in ("%inputConfiguration%") do (
    REM Current line sometimes indicates we should stop skipping, but needs to be skipped itself
    set skipOnce=FALSE
    set "LINE=%%a"
    
    REM Handle sync rules, change to mirror left-to-right
    if "!LINE!"=="    <Synchronize>" (
        set skip=TRUE
    )
    if "!LINE!"=="    </Synchronize>" (
        set skip=FALSE
        echo     ^<Synchronize^>
        echo         ^<Differences LeftOnly="right" LeftNewer="right" RightNewer="right" RightOnly="right"/^>
        echo         ^<DeletionPolicy^>Permanent^</DeletionPolicy^>
        echo         ^<VersioningFolder Style="Replace"/^>
    ) >> "%tempConfiguration%"
    REM Remove local sync rules for any applicable folder pairs
    if "!LINE!"=="            <Synchronize>" (
        set skip=TRUE
    )
    if "!LINE!"=="            </Synchronize>" (
        set skip=FALSE
        set skipOnce=TRUE
    )
    
    REM Skip 'Include' filters since they are being replaced with excluded items
    if "!LINE!"=="        <Include>" set skip=TRUE
    if "!LINE!"=="        </Include>" (
        set skip=FALSE
        set skipOnce=TRUE
    )
    if "!LINE!"=="                <Include>" set skip=TRUE
    if "!LINE!"=="                </Include>" (
        set skip=FALSE
        set skipOnce=TRUE
    )
    
    REM ------------- GLOBAL CONFIG -------------
    REM Swap 'Exclude' sections to 'Include'
    if "!LINE!"=="        <Exclude>" (
        set skipOnce=TRUE
        echo         ^<Include^>
    ) >> "%tempConfiguration%"
    REM Default exclusions that we (probably) don't want included even after swapping
    REM If you removed any of these for some reason, you'll have to figure out how to handle it
    if "!LINE!"=="            <Item>\System Volume Information\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="            <Item>\$Recycle.Bin\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="            <Item>\RECYCLE?\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="            <Item>\Recovery\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="            <Item>*\thumbs.db</Item>" (
        set skipOnce=TRUE
    )
    REM After new 'Include' section, also re-add default items to new 'Exclude' section
    if "!LINE!"=="        </Exclude>" (
        set skipOnce=TRUE
        echo         ^</Include^>
        echo         ^<Exclude^>
        echo             ^<Item^>\System Volume Information\^</Item^>
        echo             ^<Item^>\$Recycle.Bin\^</Item^>
        echo             ^<Item^>\RECYCLE?\^</Item^>
        echo             ^<Item^>\Recovery\^</Item^>
        echo             ^<Item^>*\thumbs.db^</Item^>
        echo         ^</Exclude^>
    ) >> "%tempConfiguration%"
    REM This catches the sytnax for empty 'Exclude' filters. Necessary? Maybe? Needs testing.
    REM If no global exclusions, but there are local exclusions, FFS might freak out without a global entry?
    if "!LINE!"=="        <Exclude/>" (
        set skipOnce=TRUE
        echo         ^<Include/^>
        echo         ^<Exclude/^>
    ) >> "%tempConfiguration%"
    
    REM ------------- LOCAL CONFIGS -------------
    REM Swap 'Exclude' sections to 'Include'
    if "!LINE!"=="                <Exclude>" (
        set skipOnce=TRUE
        echo                 ^<Include^>
    ) >> "%tempConfiguration%"
    REM Default exclusions that we (probably) don't want included even after swapping
    REM If you removed any of these for some reason, you'll have to figure out how to handle it
    if "!LINE!"=="                    <Item>\System Volume Information\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="                    <Item>\$Recycle.Bin\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="                    <Item>\RECYCLE?\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="                    <Item>\Recovery\</Item>" (
        set skipOnce=TRUE
    )
    if "!LINE!"=="                    <Item>*\thumbs.db</Item>" (
        set skipOnce=TRUE
    )
    REM After new 'Include' section, no default items for local 'Exclude' section
    if "!LINE!"=="                </Exclude>" (
        set skipOnce=TRUE
        echo                 ^</Include^>
        echo                 ^<Exclude/^>
    ) >> "%tempConfiguration%"
    REM This catches sytnax for empty 'Exclude' filters. Necessary? I don't think so, needs testing.
    REM Only exists if a local 'Include' filter exists and the "Exclude" filter is empty.
    REM 'Include' and 'Exclude' sections get removed in this case and inherit the global filters anyway.
    if "!LINE!"=="                <Exclude/>" (
        set skipOnce=TRUE
    ) >> "%tempConfiguration%"
    
    REM Change all <left> locations to the empty directory we created
    if "!LINE:~0,18!"=="            <Left>" (
        set skipOnce=TRUE
        echo             ^<Left^>%tempWorkingDirectory%\empty^</Left^>
    ) >> "%tempConfiguration%"
    
    if "!skip!"=="FALSE" (if "!skipOnce!"=="FALSE" echo !LINE! >> "%tempConfiguration%")
)

REM Check if the configuration was created successfully
if not exist "%tempConfiguration%" (
    echo Fatal Error: Temporary configuration file could not be found.
    exit /b 1
)

if /I "%tempConfiguration:~-5%"=="batch" (
    "%freeFileSyncLocation%" "%tempConfiguration%"
) else (
    "%freeFileSyncLocation%" "%tempConfiguration%" -Edit
)
goto Quit

:Quit
rd /s /q "%tempWorkingDirectory%"
endlocal
exit /b