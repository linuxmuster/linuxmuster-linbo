' $Id: vamt-import.vbs 1020 2011-03-18 15:07:12Z tschmitt $
' Creates a cil file which can be imported into VAMT 2.0

VAMT = "C:\Program Files\VAMT 2.0\Vamt.exe"

' Create necessary vbscript objects
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objDictionary = CreateObject("Scripting.Dictionary")
Set WshShell = WScript.CreateObject("WScript.Shell")

' Constants and variables
Const ForReading = 1

On Error Resume Next

' Command line arguments
WDataFile = WScript.Arguments(0)
OutFile = WScript.Arguments(1)

If Not objFSO.FileExists(VAMT) Then
 Usage(VAMT)
End If

If WDataFile = "" Then
 WDataFile = "workstations"
End If

If Not objFSO.FileExists(WDataFile) then
 Usage(WDataFile)
End If

If OutFile = "" Then
 OutFile = WDataFile & ".cil"
End If

' Read content of workstations file
Set objFile = objFSO.OpenTextFile (WDataFile, ForReading)
i = 0
Do Until objFile.AtEndOfStream
 strNextLine = objFile.Readline
 If TestLine(strNextLine) Then
  objDictionary.Add i, strNextLine
End If
 i = i + 1
Loop
objFile.Close

' Create computer list to add
Computers = ""
For Each strLine in objDictionary.Items
 LineArray = Split(strLine, ";", -1, 1)
 HostName = LineArray(4)
 If Computers = "" Then
  Computers = Hostname
 Else
  Computers = Computers & "," & HostName
 End If
Next

' Run VAMT.exe to add computer list
CmdLine = Chr(34) & VAMT & Chr(34) & " /a  /computers " & Computers & " /o " & Chr(34) & OutFile & Chr(34)
WScript.echo CmdLine
WshShell.Run CmdLine,  , True

' Tests if line begins with a valid char (a-z,0-9,_)
Function TestLine(strLine)
 If strLine = "" Then
  TestLine = False
  Exit Function
 End If

 FirstChar = Left(strLine, 1) 

 ' Create regexp object
 Set objRegExp = New RegExp
 strPattern = "^\w"
 objRegExp.Pattern = strPattern

 ' search pattern in line's first char
 Set Matches = objRegExp.Execute(FirstChar)	

 If Matches.Count = 1 Then
  TestLine = True
 Else
  TestLine = False
 End If
End Function

' Print usage and exit
Function Usage(notFound)
 If notFound <> "" then
  WScript.Echo notFound & " nicht gefunden!"
 End If
 WScript.Echo "Anwendung: vamt-import.vbs <Workstations-Datei> <CIL-Datei"
 WScript.Quit
End Function

