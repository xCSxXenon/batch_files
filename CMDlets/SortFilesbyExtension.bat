@echo off
setlocal enabledelayedexpansion

choice /m "This will sort ALL files in %cd%, are you sure?"
if %ERRORLEVEL%==1 goto Sort
if %ERRORLEVEL%==2 goto Cancelled
goto Error

:Sort
for %%a in (".\*") do (
    if "%%~fa" NEQ "%~f0" (
        if "%%~xa" EQU "" (
            if not exist "!extension!" mkdir "^!Files Without Extensions" 2>NUL
            move "%%a" "^!Files Without Extensions\" >NUL
        ) else (
            set extension=%%~xa
            set extension=!extension:~1!
            if not exist "!extension!" mkdir "!extension!"
            move "%%a" "!extension!\" >NUL
        )
    )
)
echo Done
goto Quit

:SortWithProgress
set total=0
for %%a in (".\*") do (
    if "%%~fa" NEQ "%~f0" (
        set /A total+=1
    )
)
set current=1
for %%a in (".\*") do (
    if "%%~fa" NEQ "%~f0" (
        if "%%~xa" EQU "" (
            if not exist "!extension!" mkdir "^!Files Without Extensions" >NUL
            move "%%a" "^!Files Without Extensions\" >NUL
        ) else (
            set extension=%%~xa
            set extension=!extension:~1!
            if not exist "!extension!" mkdir "!extension!"
            move "%%a" "!extension!\" >NUL
        )
        cls
        echo.
        echo Processed !current!/%total%
        set /A current+=1
    )
)
echo Done
goto Quit

:Error
echo You broke it
pause
Goto Quit

:Cancelled
echo Cancelled
goto Quit

:Quit
exit /b