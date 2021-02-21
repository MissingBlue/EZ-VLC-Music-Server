@echo off
setlocal enableextensions enabledelayedexpansion

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

STREAM_HOTNAME^

STREAM_PORT^

STREAM_PATH
::end of variable

set VLC.default=vlc
set VLC.dq=1
set INPUT.default=
set INPUT.dq=1
set INTERFACE.default=qt
set INTERFACE.label=--intf
set BACKGROUND_INTERFACE.default=http,oldrc
set BACKGROUND_INTERFACE.dq=1
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
set WEB_CLIENT_PORT.default=8888
set WEB_CLIENT_PORT.label=--http-port

set STREAM_PROTOCOL.default=http
set STREAM_MUXER.default=ogg
set STREAM_HOTNAME.default=
set STREAM_PORT.default=8080
set STREAM_PATH.default=

if exist "%INI_FILE_PATH%" (
	for /f "usebackq delims== tokens=1,2" %%a in ("%INI_FILE_PATH%") do (
		if defined %%a.default (
			if not "%%b"=="" (
				if "%%b"=="/" (set %%a=!%%a.default!) else (set %%a=%%b)
				if not "!%%a!"=="" (
					if defined %%a.const set %%a=!%%a.default!
					if !%%a.dq!==1 set %%a="!%%a!"
					if defined %%a.label set %%a=!%%a.label! !%%a!
				)
			)
		)
	)
)

if exist "%~1" set INPUT=%~1

for /f "usebackq delims= " %%a in ('!keys!') do (
	if not defined %%a (
		set %%a=!%%a.default!
		if !%%a.dq!==1 set %%a="!%%a!"
		if defined %%a.label set %%a=!%%a.label! !%%a!
	)
)

goto build

if "%INPUT%"=="""" (
	echo Input a file path for streaming. Empty will be canceled to execute.
	set /p INPUT=
	if "!INPUT!"=="" goto END
	set INPUT="!INPUT!"
)

if not exist %INPUT% echo No file such %INPUT% & goto END

:build
::About nesting delayed expansion.
::https://qiita.com/plcherrim/items/c7c477cacf8c97792e17
set OPTIONS=
for /f "usebackq delims= " %%a in ('!keys!') do (
	set k=%%a
	set v=!%%a!
	if not %%a==VLC if not "!k:~0,7!" == "STREAM_" set OPTIONS=!OPTIONS! !v!
)
set SOUT=-sout %STREAM_PROTOCOL%/%STREAM_MUXER%://%STREAM_HOTNAME%:%STREAM_PORT%%STREAM_PATH%
echo %VLC%%OPTIONS% %SOUT%

goto :END

"%VLC_PATH%" "%INPUT%" --intf %INTERFACE% --extraintf %BACKGROUND_INTERFACE%%OPTIONS% -sout %STREAM_PROTOCOL%/%STREAM_MUXER%://%STREAM_HOTNAME%:%STREAM_PORT%%STREAM_PATH%

:END
endlocal
pause
