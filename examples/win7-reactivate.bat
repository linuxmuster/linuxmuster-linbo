rem $Id$
rem Reaktivierung der in anon.cil gespeichterten Produkte.
rem VAMT 2.0 muss dazu installiert sein.
rem Pfade und Dateinamen sind ggf. anzupassen.

"C:\Program Files\VAMT 2.0\Vamt.exe" /c /i c:\cil\schule.cil /o c:\cil\out.cil
rmdir /Q /S c:\cil

