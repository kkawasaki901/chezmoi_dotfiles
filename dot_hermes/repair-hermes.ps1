# Run in a clean child shell; keep the caller and persistent PATH unchanged.
[CmdletBinding()]
param(
    [string[]]$Stages = @('products', 'config', 'complete'),
    [switch]$IncludeDesktop
)
$ErrorActionPreference = 'Stop'
$hermesRoot = Join-Path $env:LOCALAPPDATA 'hermes'
$installer = Join-Path $hermesRoot 'hermes-agent\scripts\install.ps1'
$shellExe = (Get-Process -Id $PID).Path
$savedPath = $env:Path
if ($IncludeDesktop -and -not $PSBoundParameters.ContainsKey('Stages')) {
    $Stages = @('desktop', 'config', 'complete')
}
try {
    $env:Path = "$env:SystemRoot\system32;$env:SystemRoot;$env:SystemRoot\System32\WindowsPowerShell\v1.0;$env:USERPROFILE\.local\bin"
    foreach ($stage in $Stages) {
        & $shellExe -NoProfile -ExecutionPolicy Bypass -File $installer -Stage $stage -NonInteractive
        if ($LASTEXITCODE -ne 0) { throw "Hermes stage '$stage' failed ($LASTEXITCODE)" }
    }
} finally {
    $env:Path = $savedPath
}
