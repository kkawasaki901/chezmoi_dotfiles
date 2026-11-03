Set shell = CreateObject("WScript.Shell")
args = ""
For i = 0 to WScript.Arguments.Count - 1
    ' Wrap each argument in quotes if it contains spaces or paths
    args = args & " """ & WScript.Arguments(i) & """"
Next
shell.Run "powershell -ExecutionPolicy Bypass -NoProfile -NonInteractive -File" & args, 0, False
