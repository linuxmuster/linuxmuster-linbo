REM Speichert Aktivierungsstatus von Windows und MSOffice
REM thomas@linuxmuster.net
REM 20170908


REM Windows
cscript //nologo %SystemRoot%\system32\slmgr.vbs /dli > %SystemDrive%\linuxmuster-win\win_activation_status


REM Office 2010 64bit
if exist "%SystemDrive%\Program Files\Microsoft Office\Office14\ospp.vbs" goto office14_64

REM office 2013 64bit
if exist "%SystemDrive%\Program Files\Microsoft Office\Office15\ospp.vbs" goto office15_64

REM office 2016 64bit
if exist "%SystemDrive%\Program Files\Microsoft Office\Office16\ospp.vbs" goto office16_64

REM Office 2010
if exist "%SystemDrive%\Program Files (x86)\Microsoft Office\Office14\ospp.vbs" goto office14

REM office 2013
if exist "%SystemDrive%\Program Files (x86)\Microsoft Office\Office15\ospp.vbs" goto office15

REM office 2016
if exist "%SystemDrive%\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" goto office16

goto ende

:office14_64
cscript //nologo "%SystemDrive%\Program Files\Microsoft Office\Office14\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office14
cscript //nologo "%SystemDrive%\Program Files (x86)\Microsoft Office\Office14\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office15_64
cscript //nologo "%SystemDrive%\Program Files\Microsoft Office\Office15\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office15
cscript //nologo "%SystemDrive%\Program Files (x86)\Microsoft Office\Office15\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office16_64
cscript //nologo "%SystemDrive%\Program Files\Microsoft Office\Office16\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status
goto ende

:office16
cscript //nologo "%SystemDrive%\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" /dstatus > %SystemDrive%\linuxmuster-win\office_activation_status


:ende
