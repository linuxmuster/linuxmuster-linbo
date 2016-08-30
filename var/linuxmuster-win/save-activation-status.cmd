REM Tasks, die beim Herunterfahren ausgeführt werden
REM thomas@linuxmuster.net
REM 11.03.2015

REM speichert Windows-Aktivierungsstatus
cscript //nologo %SystemRoot%\system32\slmgr.vbs /dli > %SystemDrive%\linuxmuster-win\win_activation_status

REM speichert Office-Aktivierungsstatus
REM Office 2010
if exist "%SystemDrive%\Program Files (x86)\Microsoft Office\Office14\ospp.vbs" goto office14
REM office 2013
if exist "%SystemDrive%\Program Files (x86)\Microsoft Office\Office15\ospp.vbs" goto office15
goto ende

:office14
cscript //nologo "%SystemDrive%\Program Files (x86)\Microsoft Office\Office14\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office15
cscript //nologo "%SystemDrive%\Program Files (x86)\Microsoft Office\Office15\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status

:ende