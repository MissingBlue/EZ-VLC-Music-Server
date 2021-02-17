@echo off
setlocal enableextensions enabledelayedexpansion

set VLC_PATH=
set INPUT=

set INTERFACE="qt"
set BACKGROUND_INTERFACE="http,oldrc"
set RANDOM_PLAYBACK=1
set LOOP_IN_PLAYLIST=1
set REPEAT_TRACK=
set AUTOPLAY=1
set PLAY_PRIOR_STREAM=1
set LIMIT_PLAYBACK_INSTANCE=1
set USE_WEB_CLIENT=1

set STREAM_PROTOCOL=http
set STREAM_MUXER=ogg
set STREAM_HOTNAME=
set STREAM_PORT=8080
set STREAM_PATH=

set OPTIONS[0].name=RANDOM_PLAYBACK
set OPTIONS[0].default=-Z
set OPTIONS[1].name=LOOP_IN_PLAYLIST
set OPTIONS[1].default=-L
set OPTIONS[2].name=REPEAT_TRACK
set OPTIONS[2].default=-R
set OPTIONS[3].name=AUTOPLAY
set OPTIONS[3].default=--playlist-autostart
set OPTIONS[4].name=PLAY_PRIOR_STREAM
set OPTIONS[4].default=--no-sout-all
set OPTIONS[5].name=LIMIT_PLAYBACK_INSTANCE
set OPTIONS[5].default=--sout-keep
set OPTIONS[5].name=LIMIT_PLAYBACK_INSTANCE
set OPTIONS[5].default=--sout-keep
set OPTIONS[6].name=USE_WEB_CLIENT
set OPTIONS[6].default=--http-port 8888

if "%VLC_PATH%" == "" set VLC_PATH=vlc
if "%INPUT%" == "" (
	echo Input a file path for streaming. Empty will be canceled to execute.
	set /p INPUT=
	if "!INPUT!"=="" goto END
)

for /l %%i in (0,1,20) do (
	if "!OPTIONS[%%i].name!"=="" (
		set /a OPTIONS_LENGTH=%%i - 1
		goto SET_OPTIONS_LENGTH
	)
)
:SET_OPTIONS_LENGTH

::About nesting delayed expansion.
::https://qiita.com/plcherrim/items/c7c477cacf8c97792e17
set OPTIONS=
for /l %%i in (0,1,!OPTIONS_LENGTH!) do (
	call set v=%%!OPTIONS[%%i].name!%%
	if !v!==1 set OPTIONS=!OPTIONS! !OPTIONS[%%i].default!
)

"%VLC_PATH%" "%INPUT%" --intf %INTERFACE% --extraintf %BACKGROUND_INTERFACE%%OPTIONS% -sout %STREAM_PROTOCOL%/%STREAM_MUXER%://%STREAM_HOTNAME%:%STREAM_PORT%%STREAM_PATH%

:END
endlocal
pause
