set debug=false
IF %debug%==false @echo off
IF "%~1"=="%%1" goto NoFileProvided
IF "%~1"=="" goto NoFileProvided


REM Set variables
set category=%~2
set series=%~3
set year=%date:~-4%
set categoryServerPath=\\fileserver\media\%category%
set showPath=%categoryServerPath%\%series%
set currentSeasonPath=%showPath%\%year%


REM Set text to prepend to the phone copy made during the 'Process' stage
set prepend=Podcast
IF "%series%"=="Regulation Gameplay" set prepend=%series%


:CurrentSeasonCheck
REM Checks if show has a season for the current year or has a local version
IF EXIST "%~dp1%category%\%series%\%year%" set currentSeasonPath=%~dp1%category%\%series%\%year%
IF NOT EXIST "%currentSeasonPath%" GOTO NotFound
GOTO GetNextSeasonAndEpisodeNumbers

:GetNextSeasonAndEpisodeNumbers
REM Get season and epsiode numbers of latest file, increment episode number, then process
for /f %%i in ('dir "%currentSeasonPath%" /b/a-d/od') do set seasonAndEpisode=%%i
IF "%seasonAndEpisode%"=="" GOTO CurrentSeasonEmpty
set seasonNumber=%seasonAndEpisode:~0,4%
set episodeNumber=%seasonAndEpisode:~4%
IF %episodeNumber% LSS 10 set episodeNumber=%episodeNumber:~1%
set /a episodeNumber=%episodeNumber%+1
IF %episodeNumber% LSS 10 set episodeNumber=0%episodeNumber%
goto Process


:NotFound
REM Current year/season folder not found for show. Determine if new show or new season/year
IF NOT EXIST "%categoryServerPath%" GOTO serverDisconnected
IF NOT EXIST "%showPath%" GOTO NewShow
goto newSeason


:newSeason
REM Show exists but it's a new year/season. Detect last season #, increment by 1, and start at E01
REM If %lastYear% starts with "Season", show is organized by "Season xx" instead of year. New seasons need to be created manually.
REM Update %currentSeasonPath% with this directory, save its number for the new file, then go back to determine next episode number.
set episodeNumber=01
for /f "tokens=*" %%i in ('dir "%showPath%" /b/ad/on') do set lastYear=%%i
IF /I %lastYear:~0,6%==Season (
    set year=%lastYear%
    set currentSeasonPath=%showPath%\%lastYear%
    set seasonNumber=S%lastYear:~7,2%E
    goto CurrentSeasonCheck
)
for /f %%i in ('dir "%showPath%\%lastYear%" /b/a-d/on') do (
    set seasonAndEpisode=%%i
    goto GotPreviousSeasonNumber
)

:GotPreviousSeasonNumber
IF "%seasonAndEpisode%"=="" set "errorMessage=Getting previous season # failed" & goto Error
set seasonNumber=%seasonAndEpisode:~1,2%
set /a seasonNumber=%seasonNumber%+1
IF %seasonNumber% LSS 10 set seasonNumber=0%seasonNumber%
set seasonNumber=S%seasonNumber%E
goto Process

:NewShow
REM Show doesn't exist yet
set seasonNumber=S01E
set episodeNumber=01
goto Process

:CurrentSeasonEmpty
REM Current season folder exists but is empty. This should only run for shows sorted by season instead of year
IF "%year%"=="%date:~-4%" set "errorMessage=Current year directory is empty and shouldn't be. Delete it if it truly is" & goto Error
set episodeNumber=01
goto Process

:Process
REM Create local directory for current season, make a phone copy, then move and rename original to organized folder
mkdir "%~dp1%category%\%series%\%year%"
copy "%~1" "%~dp1%prepend% - %~nx1"
move "%~1" "%~dp1%category%\%series%\%year%\%seasonNumber%%episodeNumber% %~nx1"
goto Quit

:Error
cls
color 04
echo.
echo Error: %errorMessage%
pause
goto Quit

:NoFileProvided
rem cls
color 04
echo No file was provided
pause
goto Quit

:serverDisconnected
rem cls
color 04
echo Not connected to server.
pause
goto Quit

:Quit
IF %debug%==true pause
exit