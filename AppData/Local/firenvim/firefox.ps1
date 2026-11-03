New-Item -Path "HKCU:\Software\Mozilla"
New-Item -Path "HKCU:\Software\Mozilla\NativeMessagingHosts"
New-Item -Path "HKCU:\Software\Mozilla\NativeMessagingHosts\firenvim"
Set-Item -Path "HKCU:\Software\Mozilla\NativeMessagingHosts\firenvim\" -Value "C:\Users\kawasaki\AppData\Local\firenvim\firenvim-firefox.json"
