@echo off
setlocal

goto :hexofargs
:HEAD

set _DPZERO_=%~dp0
if %_DPZERO_:~-1%==\ set _DPZERO_=%_DPZERO_:~0,-1%

echo [INFO] success

endlocal
exit /b 0

rem -- hex *************************************************************

:hexofargs
if P==NP (for %%I in (%*) do set _=[%*])
echo.%*| findstr /r "[<>&|^]" > NUL
if %errorlevel% EQU 0 goto :hexofargs_ERROR
echo.%*| findstr /r /c:"[^ ,;=][\"\"][^ ,;=]" > NUL
if %errorlevel% EQU 0 goto :hexofargs_ERROR
:hexofargs_RETURN
goto :HEAD
:hexofargs_ERROR
echo [ERROR] invalid arguments
exit /b 1
