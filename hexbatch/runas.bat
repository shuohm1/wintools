@echo off
powershell Start-Process ".\privilege.bat" -Verb runas
exit /b
