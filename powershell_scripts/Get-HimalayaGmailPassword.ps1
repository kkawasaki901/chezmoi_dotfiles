$ErrorActionPreference = 'Stop'

$secretPath = Join-Path $env:APPDATA 'himalaya\gmail-app-password.dpapi'

if (-not (Test-Path -LiteralPath $secretPath)) {
    throw "Gmail app password is not registered. Run Set-HimalayaGmailPassword.ps1 first."
}

$encryptedPassword = (Get-Content -LiteralPath $secretPath -Raw).Trim()
$securePassword = $encryptedPassword | ConvertTo-SecureString
$credential = [pscredential]::new('gmail', $securePassword)
$credential.GetNetworkCredential().Password
