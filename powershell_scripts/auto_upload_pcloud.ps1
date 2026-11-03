$VbsPath = "C:\Users\kawasaki\powershell_scripts\run_pcloud_hidden.vbs"
$TaskName = "Upload Photos to pCloud"

$Action = New-ScheduledTaskAction `
  -Execute "wscript.exe" `
  -Argument "//B `"$VbsPath`""

$Trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask `
  -TaskName $TaskName `
  -Action $Action `
  -Trigger $Trigger `
  -Description "Resume rclone photo upload to pCloud at logon" `
  -Force