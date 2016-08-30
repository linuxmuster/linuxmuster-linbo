REM custom.cmd example
REM thomas@linuxmuster.net
REM 18.11.2015
REM

REM Beispiel: Maschinenaccount Passwort setzen
%SystemDrive%\linuxmuster-win\lsaSecretStore.exe "$MACHINE.ACC" 12345678
