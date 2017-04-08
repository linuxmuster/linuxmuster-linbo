REM Installiert geplante Aufgaben für linuxmuster.net
REM thomas@linuxmuster.net
REM 21.09.2015

REM alte Tasks zuerst deinstallieren
call %SystemDrive%\linuxmuster-win\uninstall.cmd

REM erstellt linuxmuster-start-tasks, die beim Start ausgeführt werden
schtasks /Create /XML %SystemDrive%\linuxmuster-win\start-tasks.xml /TN linuxmuster-start-tasks
