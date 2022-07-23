@echo off
powershell Start-Process ".\__privilege__.bat" -Verb runas
exit /b
