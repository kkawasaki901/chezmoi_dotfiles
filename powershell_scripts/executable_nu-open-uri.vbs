Option Explicit

Dim shell, uri, command
uri = WScript.Arguments(0)

Set shell = CreateObject("WScript.Shell")
command = """C:\Program Files\PowerShell\7\pwsh.exe""" _
    & " -NoProfile -ExecutionPolicy Bypass -File " _
    & """C:\Users\kawasaki\powershell_scripts\nu-open-uri.ps1""" _
    & " """ & Replace(uri, """", """""") & """"

' Window style 0 keeps the short-lived PowerShell handler completely hidden.
shell.Run command, 0, False
