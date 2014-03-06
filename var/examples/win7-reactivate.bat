rem thomas@linuxmuster.net
rem 05.10.2013
rem Reaktivierung der in schule.cil gespeichterten Produkte.
rem VAMT 2.0 muss dazu installiert sein.
rem Pfade und Dateinamen sind ggf. anzupassen.

@echo off

if exist "%PROGRAMFILES(X86)%" goto set32path
VAMT="%PROGRAMFILES%\VAMT 2.0\Vamt.exe"
goto main

:set32path
VAMT="%PROGRAMFILES(X86)%\VAMT 2.0\Vamt.exe"

:main
set WorkDir=C:\cil
set InFile=%WorkDir%\schule.cil
set OutFile=%WorkDir%\out.cil

if not exist ""%VAMT%"" goto end
if not exist %InFile% goto end

""%VAMT%"" /c /i %InFile% /o %OutFile%

rmdir /Q /S %WorkDir%

:end
