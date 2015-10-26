REM Tasks, die beim Start ausgeführt werden
REM thomas@linuxmuster.net
REM 26.10.2015

REM Reaktivierung starten, falls Linbo die cmd-Datei angelegt hat
if exist %SystemDrive%\linuxmuster-win\winact.cmd goto winact
goto winact_end

:winact
call %SystemDrive%\linuxmuster-win\winact.cmd
del %SystemDrive%\linuxmuster-win\winact.cmd
:winact_end

REM Maschinenpasswort beim Start setzen
if exist %SystemDrive%\linuxmuster-win\set_machinepw.cmd goto set_machinepw
goto set_machinepw_end

:set_machinepw
call %SystemDrive%\linuxmuster-win\set_machinepw.cmd
del %SystemDrive%\linuxmuster-win\set_machinepw.cmd
:set_machinepw_end

REM Eigenes Skript aufrufen, falls vorhanden
if exist %SystemDrive%\linuxmuster-win\custom.cmd call %SystemDrive%\linuxmuster-win\custom.cmd
