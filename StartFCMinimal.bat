@echo off
title FCCL
if EXIST "drivers\etc\hosts" cd "%~dp0"

if NOT EXIST "gameinfo.txt" (
	echo Cannot run this script outside of a source mods directory...
	pause
	exit
)

rem Get Resolution of the screen
for /f "tokens=4,5 delims=. " %%a in ('ver') do set "version=%%a%%b"
if version lss 62 (
	for /f "tokens=* delims=" %%f in ('wmic desktopmonitor get screenwidth /format:value') do (
		for /f %%a in ("%%f") do set "x=%%a"
	)
	for /f "tokens=* delims=" %%f in ('wmic desktopmonitor get screenheight /format:value') do (
		for /f %%a in ("%%f") do set "y=%%a"
	)
) else (
	for /f "tokens=1,2,* delims=" %%f in ('wmic path Win32_VideoController get CurrentHorizontalResolution') do (
		for /f %%a in ("%%f") do set "x=%%a"
	)
	for /f "tokens=1,2,* delims=" %%f in ('wmic path Win32_VideoController get CurrentVerticalResolution') do (
		for /f %%a in ("%%f") do set "y=%%a"
	)
)

set skipindex=1
set cldir=""
set cldrive=""
for /f "skip=2 tokens=1,2* delims== " %%i in ('reg QUERY HKEY_CURRENT_USER\Software\Valve\Steam /f SteamPath /t REG_SZ /v') do set "cldir=%%k" & goto start
:start
for /f "delims=" %%V in ('powershell -command "$env:cldir.Replace(\"/\",\"\\\")"') do set "cldir=%%V"
if EXIST "%cldir%\steamapps\common\Source SDK Base 2013 Multiplayer\hl2.exe" goto startcl
set cldirs=
for /f "skip=%skipindex% tokens=1,2* delims==\\ " %%i in ('findstr .path. "%cldir%\steamapps\libraryfolders.vdf" ') do set "cldirs=%%j" & set "cldrive=%%i" & goto compare
goto cannotfind

:compare
set cldirs=%cldirs:~0,-1%
set "cldrive=%cldrive:~-2%"
set "cldirs=%cldrive%\%cldirs%"
rem break out of loop if too many attempts
if '%skipindex%'=='10' goto cannotfind
rem echo Checking if installed at: %cldirs%
if EXIST "%cldirs%\steamapps\common\Source SDK Base 2013 Multiplayer\hl2.exe" (
	set "cldir=%cldirs%"
	goto startcl
)
set /a skipindex+=1
goto start

:startcl
rem If we either didn't get a valid resolution, or the resolution is lower than 640 just run windowed.
if %x% LEQ 640 (
	start /b "FCCL" "%cldir%\steamapps\common\Source SDK Base 2013 Multiplayer\hl2.exe" -steam -game "%CD%" -windowed -multirun -novid -nosplash"
)
start /b "FCCL" "%cldir%\steamapps\common\Source SDK Base 2013 Multiplayer\hl2.exe" -steam -game "%CD%" -windowed -noborder -w %x% -h %y% -multirun -novid -nosplash"
exit

:cannotfind
echo Could not determine location of Source SDK Base 2013 Multiplayer...
pause
exit
