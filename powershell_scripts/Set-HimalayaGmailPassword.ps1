$ErrorActionPreference = 'Stop'

$configDirectory = Join-Path $env:APPDATA 'himalaya'
$secretPath = Join-Path $configDirectory 'gmail-app-password.dpapi'

New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null

$securePassword = Read-Host 'Googleで発行した16桁のGmailアプリパスワードを入力してください' -AsSecureString
$securePassword | ConvertFrom-SecureString | Set-Content -LiteralPath $secretPath -Encoding utf8NoBOM

Write-Host 'Himalaya用GmailアプリパスワードをWindows DPAPIで暗号化保存しました。'
Write-Host '接続確認: himalaya account check'
