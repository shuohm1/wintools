@echo off
setlocal

goto :hexofargs
:HEAD

set _DPZERO_=%~dp0
if %_DPZERO_:~-1%==\ set _DPZERO_=%_DPZERO_:~0,-1%

rem -- check privileges
openfiles 1> NUL 2>&1
if %errorlevel% NEQ 0 (
	call :printerror /w "you have no administrator privileges"
	goto :restartrunas
) else (
	call :printerror /i "you have administrator privileges"
)

set num_args=0
for %%I in (%*) do set /a num_args += 1
if %num_args% EQU 0 call :printerror /d "there are no arguments"
for %%I in (%*) do call :printerror /d "${W*}%%~I${D}"

pause

endlocal
exit /b

rem -- hex *************************************************************

:hexofargs
rem -- reject raw special characters
if P==NP (
	for %%I in (%*) do echo.
	set _=[%*]
)

rem -- reject quoted special characters
echo.%*| findstr /r /c:"[<>&|^]" > NUL
if %errorlevel% EQU 0 (
	call :printerror "invalid arguments"
	exit /b 1
)

rem -- detect bad quotation
echo.%*| findstr /r /c:"[^ ,;=][\"\"][^ ,;=]" > NUL
if %errorlevel% NEQ 0 goto :hexofargs_RETURN

rem -- reconstruct arguments
set newargs="%~f0"
for %%I in (%*) do (
	rem -- dequote
	set tmpvar=%%~I
	rem -- replace double quotation signs to single quotation signs
	call set newargs=%%newargs%% "%%tmpvar:"='%%"
)

rem -- just make sure to avoid infinite recursions
echo.%newargs%| findstr /r /c:"[^ ,;=][\"\"][^ ,;=]" > NUL
if %errorlevel% EQU 0 (
	call :printerror "bad quotation"
	exit /b 1
)

rem -- call myself with reconstructed arguments
call %newargs%
exit /b %errorlevel%

:hexofargs_RETURN
goto :HEAD

rem --------------------------------------------------------------------

:restartrunas
rem -- reconstruct arguments
set newargs=\"%~f0\"
for %%I in (%*) do (
	rem -- dequote
	set tmpvar=%%~I
	rem -- escape single/double quotation signs
	call set newargs=%%newargs%% \"%%tmpvar:'=''%%\"
)

rem -- cmd '/c \"\"C:\path\to\my self.bat\" \"arg a\" \"arg b\"\"'
rem --     <----------------------------------------------------->
rem --          "\"C:\path\to\my self.bat\" \"arg a\" \"arg b\""
rem --          <---------------------------------------------->
rem --            "C:\path\to\my self.bat"   "arg a"   "arg b"
rem --            <---------------------->   <----->   <----->

rem -- restart myself with privileges
powershell start-process cmd '/c \"%newargs%\"' -verb runas
rem -- do not wait the new process and exit the old process
exit /b 0

rem -- subroutines *****************************************************

:printerror
@echo off
setlocal

rem -- if just step on "goto :printerror"
if not "%~0" == ":printerror" (
	set msg={0}[1;31m[ERROR] %~n0: something is wrong{0}[0m
	goto :printerror_output
)

set _COLORS_=K,R,G,Y,B,M,C,W
set prefix=${R*}[ERROR]${D}
set nshift=1

rem -- set prefix
for %%X in (%*) do (
	if /i "%%X" == "/i" call :printerror_prefix G INFO
	if /i "%%X" == "/d" call :printerror_prefix C DEBUG
	if /i "%%X" == "/w" call :printerror_prefix Y WARNING
	if /i "%%X" == "/n" call :printerror_noprefix
)
if not "%prefix%" == "" set prefix=%prefix% %~n0: 
call set msg=%%prefix%%%%~%nshift%${D}
goto :printerror_prefix_TAIL

:printerror_prefix
	set prefix=${%~1}[%~2]${D}
	set /a nshift += 1
	exit /b
:printerror_noprefix
	set prefix=
	set /a nshift += 1
	exit /b
:printerror_prefix_TAIL

rem -- interpret colors
set index=0
for %%X in (%_COLORS_%) do call :printerror_colors %%X
for %%X in (%_COLORS_%) do call :printerror_colors %%X*
set msg=%msg:${D}={0}[0m%
goto :printerror_colors_TAIL

:printerror_colors
	call set msg=%%msg:${%~1}={0}[38;5;%index%m%%
	set /a index += 1
	exit /b
:printerror_colors_TAIL

rem -- escape single quotation signs
set msg=%msg:'={2}%

:printerror_output
rem -- 0x1b: escape
rem -- 0x22: double quotation sign
rem -- 0x27: single quotation sign
1>&2 powershell -command "'%msg%' -f [char]0x1b,[char]0x22,[char]0x27"

endlocal
exit /b 1
