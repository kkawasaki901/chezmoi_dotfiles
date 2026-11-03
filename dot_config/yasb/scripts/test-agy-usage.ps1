$ErrorActionPreference = 'Stop'
$scriptPath = Join-Path $PSScriptRoot 'agy-usage.ps1'
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$errors)
if ($errors.Count) { throw ($errors | Out-String) }
$function = $ast.Find({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Invoke-BoundedUsage' }, $true)
Invoke-Expression $function.Extent.Text
$testDir = Join-Path $env:TEMP ('yasb-agy-test-' + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $testDir | Out-Null
$shell = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
try {
    $result = Invoke-BoundedUsage -Executable $shell -Arguments '-NoProfile -Command "Write-Output quota-ok"' -WorkingDirectory $testDir
    if ($result.Trim() -ne 'quota-ok') { throw 'Success output mismatch' }
    'PASS: success output'
    $timer = [Diagnostics.Stopwatch]::StartNew()
    try {
        Invoke-BoundedUsage -Executable $shell -Arguments '-NoProfile -Command "Start-Sleep -Seconds 30"' -WorkingDirectory $testDir -TimeoutSeconds 1
        throw 'Timeout was not enforced'
    } catch {
        if ($_.Exception.Message -ne 'AGY refresh timed out') { throw }
    }
    if ($timer.Elapsed.TotalSeconds -gt 6) { throw 'Timeout cleanup too slow' }
    'PASS: timeout and process cleanup'
    try {
        Invoke-BoundedUsage -Executable $shell -Arguments '-NoProfile -Command "exit 7"' -WorkingDirectory $testDir
        throw 'Exit failure not detected'
    } catch {
        if ($_.Exception.Message -ne 'AGY exited with code 7') { throw }
    }
    'PASS: nonzero exit'
    if (@(Get-ChildItem $testDir).Count) { throw 'Temporary output files leaked' }
    'PASS: temporary output cleanup'
    $data = & $shell -NoProfile -ExecutionPolicy Bypass -File $scriptPath -CacheOnly | ConvertFrom-Json
    if (-not $data.text -or -not $data.tooltip) { throw 'Invalid widget JSON' }
    'PASS: cached widget JSON'
} finally {
    # Only the empty, unique test directory is removed.
    Remove-Item -LiteralPath $testDir -ErrorAction SilentlyContinue
}
