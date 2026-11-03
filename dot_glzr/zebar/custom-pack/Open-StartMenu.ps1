# Open the Windows Start menu (Ctrl+Esc).
$shell = New-Object -ComObject WScript.Shell
$shell.SendKeys('^{ESC}')
