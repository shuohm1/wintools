@echo off
setlocal

set _DPZERO_=%~dp0
if %_DPZERO_:~-1%==\ set _DPZERO_=%_DPZERO_:~0,-1%

rem -- HEX *************************************************************
if P==NP (for %%I in (%*) do set _=[%*])
echo.%*| findstr /r "[<>&|^]" > NUL
if %errorlevel% EQU 0 goto :printerror
echo.%*| findstr /r /c:"[^ ,;=][\"\"][^ ,;=]" > NUL
if %errorlevel% EQU 0 goto :printerror
rem ********************************************************************

rem -- HEX *************************************************************
rem -- reject raw special characters
if P==NP (
	for %%I in (%*) do echo.
	set _=[%*]
)

rem -- reject quoted special characters
echo.%*| findstr /r "[<>&|^]" > NUL
set tmpval=%errorlevel%
if %tmpval% EQU 0 (
	call :printerror "invalid arguments"
	exit /b 1
)

rem -- reject bad quotation
for %%I in (%*) do call :subhex %%I
if %tmpval% EQU 0 (
	call :printerror "bad quotation"
	exit /b 1
)

goto :subhex_TAIL
:subhex
	set _=%1
	rem -- ERROR if %~1 has unpaired quotation signes
	rem ## if not "%~1"=="%_:"=%" set /a tmpval *= 0 & rem "
	rem -- WORKAROUND: %~1 -> %%~J
	for %%J in (%1) do if not "%%~J"=="%_:"=%" set /a tmpval *= 0 & rem "
	exit /b
:subhex_TAIL
rem ********************************************************************

rem for %%I in (%*) do call :printerror /d "${W*}%%~I${D}"
call :printerror /i "success"

endlocal
exit /b 0

rem -- subroutines

:printerror
@echo off
setlocal
if not "%~0" == ":printerror" (
	set msg={0}[1;31m[ERROR] %~n0: something is wrong{0}[0m
	goto :printerror_output
)
set _COLORS_=K,R,G,Y,B,M,C,W
set prefix=${R*}[ERROR]${D}
set nshift=1
for %%X in (%*) do (
	if /i "%%X" == "/i" call :printerror_prefix G INFO
	if /i "%%X" == "/d" call :printerror_prefix C DEBUG
	if /i "%%X" == "/w" call :printerror_prefix Y WARNING
	if /i "%%X" == "/n" call :printerror_noprefix
)
if not "%prefix%" == "" set prefix=%prefix% %~n0: 
call set msg=%%prefix%%%%~%nshift%${D}
set index=0
for %%X in (%_COLORS_%) do call :printerror_colors %%X
for %%X in (%_COLORS_%) do call :printerror_colors %%X*
set msg=%msg:${D}={0}[0m%
set msg=%msg:'={2}%
:printerror_output
1>&2 powershell -command "'%msg%' -f [char]0x1b,[char]0x22,[char]0x27"
endlocal
exit /b 1
:printerror_prefix
set prefix=${%~1}[%~2]${D}
set /a nshift += 1
exit /b
:printerror_noprefix
set prefix=
set /a nshift += 1
exit /b
:printerror_colors
call set msg=%%msg:${%~1}={0}[38;5;%index%m%%
set /a index += 1
exit /b
