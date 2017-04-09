REM entfernt die geplanten linuxmuster-tasks
REM thomas@linuxmuster.net
REM 21.09.2015

schtasks /delete /TN linuxmuster-start-tasks /f
schtasks /delete /TN linuxmuster-shutdown-tasks /f
