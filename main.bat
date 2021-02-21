@echo off&setlocal enableextensions enabledelayedexpansion


set INI_FILE_PATH=main.ini


::begin of variable
set keys=VLC^

INPUT^

INTERFACE^

BACKGROUND_INTERFACE^

RANDOM^

LOOP^

REPEAT^

AUTOPLAY^

PLAY_PRIOR_ONLY^

LIMIT_INSTANCE^

WEB_CLIENT_PORT^

STREAM_PROTOCOL^

STREAM_MUXER^

STREAM_HOSTNAME^

STREAM_PORT^

STREAM_PATH^

CMD_WINDOW_STATE
::end of variable

if exist "%PROGRAMFILES%\VideoLAN\VLC\vlc.exe" (
	set VLC.default=%PROGRAMFILES%\VideoLAN\VLC\vlc.exe
) else if exist "%PROGRAMFILES(X86)%\VideoLAN\VLC\vlc.exe" (
	set VLC.default="%PROGRAMFILES(X86)%\VideoLAN\VLC\vlc.exe"&set VLC.wq=
)
if not defined VLC.wq set VLC.wq=1
set INPUT.default=
set INPUT.wq=1
set INTERFACE.default=qt
set INTERFACE.label=--intf
set BACKGROUND_INTERFACE.default=http,oldrc
set BACKGROUND_INTERFACE.wq=1
set BACKGROUND_INTERFACE.label=--extraintf
set RANDOM.default=-Z
set RANDOM.const=1
set LOOP.default=-L
set LOOP.const=1
set REPEAT.default=-R
set REPEAT.const=1
set AUTOPLAY.default=--playlist-autostart
set AUTOPLAY.const=1
set PLAY_PRIOR_ONLY.default=--no-sout-all
set PLAY_PRIOR_ONLY.const=1
set LIMIT_INSTANCE.default=--sout-keep
set LIMIT_INSTANCE.const=1
set WEB_CLIENT_PORT.default=8088
set WEB_CLIENT_PORT.label=--http-port

set STREAM_PROTOCOL.default=http
set STREAM_MUXER.default=ogg
set STREAM_HOSTNAME.default=
set STREAM_PORT.default=8080
set STREAM_PATH.default=

set CMD_WINDOW_STATE.default=0
set CMD_WINDOW_STATE.sw=1
set CMD_WINDOW_STATE[0]=
set CMD_WINDOW_STATE[1]=/min
set CMD_WINDOW_STATE[2]=/max

set debug_mode=1

if exist "%INI_FILE_PATH%" (
	for /f "usebackq delims== tokens=1,2" %%a in ("%INI_FILE_PATH%") do (
		if defined %%a.default if not "%%b"=="" (
			if "%%b"=="/" (set %%a=!%%a.default!) else (set %%a=%%b)
			if not "!%%a!"=="" (
				if defined %%a.const set %%a=!%%a.default!
				if !%%a.wq!==1 set %%a="!%%a!"
				if defined %%a.label set %%a=!%%a.label! !%%a!
			)
		)
		set %%a.defined=1
	)
)

if exist "%~1" set INPUT=%~1

:: About nesting delayed expansion.
:: https://qiita.com/plcherrim/items/c7c477cacf8c97792e17
for /f "usebackq delims= " %%a in ('!keys!') do (
	if "!%%a.sw!"=="1" (
		if not defined %%a[!%%a!] set %%a=!%%a.default!
		call set %%a=%%%%a[!%%a!]%%
	) else if not defined %%a.defined (
		set %%a=!%%a.default!
		if !%%a.wq!==1 set %%a="!%%a!"
		if defined %%a.label set %%a=!%%a.label! !%%a!
	)
)

if "%debug_mode%"=="1" goto build

call :input_path VLC ""vlc.exe""
call :input_path INPUT "file path"

:build
set OPTIONS=&set CMD=
for /f "usebackq delims= " %%a in ('!keys!') do (
	if defined %%a (
		set k=%%a&set v=!%%a!
		if not %%a==VLC if not "!k:~0,7!" == "STREAM_" (
			if "!k:~0,4!" == "CMD_" (set CMD=!CMD! !v!) else (set OPTIONS=!OPTIONS! !v!)
		)
	)
)
set SOUT= --sout %STREAM_PROTOCOL%/%STREAM_MUXER%://%STREAM_HOSTNAME%:%STREAM_PORT%%STREAM_PATH%
if "%SOUT%"== "--sout /://" set SOUT=

:END
if "%debug_mode%"=="1" (echo ""!CMD! %VLC%%OPTIONS%%SOUT%&pause) else (start ""!CMD! %VLC%%OPTIONS%%SOUT%)
endlocal&exit

:input_path
if not exist !%1! (
	echo;&echo No such a file: !%1!
	set %1=
	call :input %1 %2
	if defined %1.wq if %1.wq==1 (set %1="!%1!") else (set %1=!%1!)
	call :input_path %1 %2
)
exit /b
:input
echo Input a path for %~2. Empty will be canceled to execute.&echo;
echo * * * * * * * * * * * * * * * * * * * * * * * * * * * *
echo   Please do NOT put double quotes(") at any position.
echo * * * * * * * * * * * * * * * * * * * * * * * * * * * *
set /p %1=
if "!%1!"=="" goto END
exit /b
