rem $Id: win7-reactivate.bat 1020 2011-03-18 15:07:12Z tschmitt $
rem Reaktivierung der in schule.cil gespeichterten Produkte.
rem VAMT 2.0 muss dazu installiert sein.
rem Pfade und Dateinamen sind ggf. anzupassen.

@echo off

set VAMT="C:\Program Files\VAMT 2.0\Vamt.exe"
set WorkDir=C:\cil
set InFile=%WorkDir%\schule.cil
set OutFile=%WorkDir%\out.cil

if not exist ""%VAMT%"" goto end
if not exist %InFile% goto end

""%VAMT%"" /c /i %InFile% /o %OutFile%

rmdir /Q /S %WorkDir%

:end
