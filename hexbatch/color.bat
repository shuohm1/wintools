@echo off
setlocal
rem powershell -command "'foo{0}[1;32mbar{0}[0mbaz' -f [char]0x1b"

set _DPZERO_=%~dp0
if "%_DPZERO_:~-1%" == "\" set _DPZERO_=%_DPZERO_:~0,-1%

set HEXDIGITS=0123456789abcdef
set TWENTYFOURBIT=24bit-colors.txt

set buffer=

echo ^<ESC^>[XXm-----------------------^<ESC^>[0m
for /L %%I in (30,1,37) do call :append_to_buffer %%I "e[%%Im*****"
call :flush_buffer
for /L %%I in (90,1,97) do call :append_to_buffer %%I "e[%%Im*****"
call :flush_buffer
echo.

echo ^<ESC^>[38;5;XXm------------------^<ESC^>[0m
for /L %%I in (0,1,7)  do call :append_indexcolor %%I "******"
call :flush_buffer
for /L %%I in (8,1,15) do call :append_indexcolor %%I "******"
call :flush_buffer

for /L %%I in (0,1,5) do (
	for /L %%J in (0,1,5) do (
		for /L %%K in (0,1,5) do call :append_colorful %%I %%J %%K
		call :flush_buffer
	)
)
goto :append_colorful_TAIL

:append_colorful
	set /a index = 16 + %~1 * 36 + %~2 * 6 + %~3
	set codebuffer=
	call :append_hexcode %~1
	call :append_hexcode %~2
	call :append_hexcode %~3
	call :append_indexcolor %index% "%codebuffer%"
	exit /b
:append_hexcode
		set foobar=%~1
		if %foobar% GTR 0 set /a foobar= %foobar% * 40 + 55
		set /a foo = %foobar% / 16
		set /a bar = %foobar% %% 16
		set codebuffer=%codebuffer%%%HEXDIGITS:~%foo%,1%%%%HEXDIGITS:~%bar%,1%%
		exit /b
:append_colorful_TAIL

for /L %%I in (0,1,2) do (
	for /L %%J in (0,1,7) do call :append_grayscale %%I %%J
	call :flush_buffer
)
echo.
goto :append_grayscale_TAIL

:append_grayscale
	set /a index = 232 + %~1 * 8 + %~2
	set /a foobar = %~1 * 80 + %~2 * 10 + 8
	set /a foo = %foobar% / 16
	set /a bar = %foobar% %% 16
	set codebuffer=%%HEXDIGITS:~%foo%,1%%%%HEXDIGITS:~%bar%,1%%
	call :append_indexcolor %index% "%codebuffer%%codebuffer%%codebuffer%"
	exit /b
:append_grayscale_TAIL

for /F "usebackq eol=; tokens=1,2,3,4,5,6,7 delims=," %%I in ("%_DPZERO_%\%TWENTYFOURBIT%") do (
	call :append_24bitcolor 38 %%M %%N %%O "*"
)
call :append_resetcolor

echo ^<ESC^>[38;2;R;G;Bm---------------^<ESC^>[0m
call :flush_buffer

for /F "usebackq eol=; tokens=1,2,3,4,5,6,7 delims=," %%I in ("%_DPZERO_%\%TWENTYFOURBIT%") do (
	call :append_24bitcolor 48 %%M %%N %%O " "
)
call :append_resetcolor

echo ^<ESC^>[48;2;R;G;Bm---------------^<ESC^>[0m
call :flush_buffer

endlocal
exit /b

:append_24bitcolor
set buffer=%buffer%{0}[%~1;2;%~2;%~3;%~4m%~5
exit /b

:append_resetcolor
set buffer=%buffer%{0}[0m
exit /b

:append_indexcolor
set withpad=  %~1
call :append_to_buffer "38;5;%~1" "%withpad:~-3%#%~2"
exit /b

:append_to_buffer
set buffer=%buffer%{0}[%~1m%~2{0}[0m 
exit /b

:flush_buffer
if "%buffer%" == "" goto :flush_buffer_RETURN
if not "%buffer:~-1%" == " " (
	powershell -command "'%buffer%' -f [char]0x1b"
) else (
	powershell -command "'%buffer:~0,-1%' -f [char]0x1b"
)
set buffer=
:flush_buffer_RETURN
exit /b
