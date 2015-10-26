REM Setzt das Maschinenpasswort
REM thomas@linuxmuster.net
REM 26.10.2015
REM

REM Passwort setzen
%SystemDrive%\linuxmuster-win\lsaSecretStore.exe "$MACHINE.ACC" @@machinepw@@

REM Programm wieder loeschen
del %SystemDrive%\linuxmuster-win\lsaSecretStore.exe