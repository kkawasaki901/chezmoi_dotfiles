Option Explicit
On Error Resume Next

Dim objShell
Dim exitcode
Dim ps1

ps1 = "C:\Users\kawasaki\powershell_scripts\pcloud_picture.ps1"

Set objShell = CreateObject("WScript.Shell")

exitcode = objShell.Run("""C:\Program Files\PowerShell\7\pwsh.exe"" -NoProfile -ExecutionPolicy Bypass -File """ & ps1 & """", 0, True)

WScript.Quit(exitcode)