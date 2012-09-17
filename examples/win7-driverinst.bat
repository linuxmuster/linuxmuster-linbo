rem $Id: win7-driverinst.bat 993 2011-03-09 14:17:35Z tschmitt $
rem Installiert alle Treiber, die sich unterhalb des auf der Kommandozeile
rem uebergebenen Verzeichnisses befinden.
rem Aufruf:
rem win7-driverinst <Verzeichnis>
rem Beispiel:
rem win7-driverinst C:\drivers

@ Echo off

set driverdir=%1%

if "%driverdir%"=="" goto end

if not exist %driverdir% goto end

cd %driverdir%

echo Installing Drivers Please wait....
for /f %%i in ('dir/b /s *.inf') do pnputil.exe -i -a %%i

:end

