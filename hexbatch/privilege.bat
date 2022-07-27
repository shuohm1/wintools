@echo off

openfiles 1> NUL 2>&1
if %errorlevel% EQU 0 (
	echo you have administrator privileges
	exit /b 0
) else (
	echo you have no administrator privileges
	exit /b 1
)
