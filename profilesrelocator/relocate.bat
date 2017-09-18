@echo off
setlocal
set answerfile=D:\relocate.xml

if not exist %answerfile% (
	echo no such file: %answerfile%
	pause
	exit /b 1
)

net stop wmpnetworksvc
%windir%\system32\sysprep\sysprep.exe /oobe /reboot /unattend:%answerfile%

endlocal
exit /b
