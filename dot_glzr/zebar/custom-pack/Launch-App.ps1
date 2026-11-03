param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(0, 99)]
    [int]$Index
)

$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'apps.json'
$apps = @(Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json)

if ($Index -ge $apps.Count) {
    throw "App index $Index does not exist."
}

$app = $apps[$Index]
if (-not (Test-Path -LiteralPath $app.program) -and $app.program -notmatch '^[a-zA-Z0-9_.-]+$') {
    throw "Program not found: $($app.program)"
}

$startArgs = @{
    FilePath = [string]$app.program
}
if (-not [string]::IsNullOrWhiteSpace([string]$app.args)) {
    $startArgs.ArgumentList = [string]$app.args
}
Start-Process @startArgs
