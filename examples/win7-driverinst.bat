rem $Id$

@ Echo off

set driverdir=%1%

if "%driverdir%"=="" goto end

if not exist %1% goto end

cd %driverdir%

echo Installing Drivers Please wait....
for /f %%i in ('dir/b /s *.inf') do pnputil.exe -i -a %%i

:end

