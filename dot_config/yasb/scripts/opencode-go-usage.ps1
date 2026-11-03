param([switch]$CacheOnly)
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$stateDir = Join-Path $env:LOCALAPPDATA 'yasb-opencode-go'
$cache = Join-Path $stateDir 'usage.json'
$attempt = Join-Path $stateDir 'attempt.txt'
$failure = Join-Path $stateDir 'failed.txt'
$data = $null
$owned = $false
$mutex = New-Object Threading.Mutex($false, 'Local\YASB-OpenCodeGoUsage')
try {
    if (-not $CacheOnly) {
        try { $owned = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $owned = $true }
        if ($owned) {
            New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
            $recent = (Test-Path $attempt) -and (((Get-Date).ToUniversalTime() - (Get-Item $attempt).LastWriteTimeUtc).TotalSeconds -lt 300)
            if (-not $recent) {
                [IO.File]::WriteAllText($attempt, [DateTimeOffset]::UtcNow.ToString('o'))
                $key = $env:OPENCODE_GO_API_KEY
                if (-not $key) { $key = [Environment]::GetEnvironmentVariable('OPENCODE_GO_API_KEY', 'User') }
                $authPath = Join-Path $env:USERPROFILE '.local\share\opencode\auth.json'
                if (-not $key -and (Test-Path $authPath)) {
                    $auth = Get-Content -LiteralPath $authPath -Raw | ConvertFrom-Json
                    $key = $auth.'opencode-go'.key
                    if (-not $key) { $key = $auth.opencode.key }
                }
                # Reuse the existing Go configuration; never copy keys into YASB.
                $envFile = Join-Path $env:USERPROFILE 'codex\260618_tauri_obsidian\tools\.env'
                if (-not $key -and (Test-Path $envFile)) {
                    $line = Get-Content -LiteralPath $envFile | Where-Object { $_ -match '^\s*OPENCODE_GO_API_KEY\s*=' } | Select-Object -First 1
                    if ($line) { $key = ($line -split '=', 2)[1].Trim().Trim('"').Trim("'") }
                }
                if (-not $key) { throw 'No Go credential available' }
                $response = Invoke-RestMethod -Uri 'https://opencode.ai/zen/go/v1/usage' -Headers @{Authorization="Bearer $key"} -TimeoutSec 10 -MaximumRedirection 0
                foreach ($name in @('rolling', 'weekly', 'monthly')) {
                    $value = $response.usage.$name
                    if ($null -eq $value.percent -or $value.percent -isnot [ValueType]) { throw 'Invalid usage response' }
                }
                # Persist quota fields only, never authentication or account data.
                $data = [pscustomobject]@{ usage=$response.usage; updated=[DateTimeOffset]::UtcNow.ToString('o') }
                $tmp = $cache + '.tmp'
                [IO.File]::WriteAllText($tmp, ($data | ConvertTo-Json -Depth 8), (New-Object Text.UTF8Encoding($false)))
                if (Test-Path $cache) { [IO.File]::Replace($tmp, $cache, ($cache + '.previous')) }
                else { [IO.File]::Move($tmp, $cache) }
                if (Test-Path $failure) { Remove-Item -LiteralPath $failure -Force }
            }
        }
    }
} catch {
    # Do not serialize exception details, headers or credentials.
    if (Test-Path $stateDir) { [IO.File]::WriteAllText($failure, 'Quota refresh failed') }
} finally {
    $key = $null
    if ($owned) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
if (-not $data -and (Test-Path $cache)) {
    try { $data = Get-Content -LiteralPath $cache -Raw | ConvertFrom-Json } catch {}
}
$result = @{ text="Go`nQuota unavailable"; alt='OpenCode Go --'; tooltip='OpenCode Go: quota unavailable; check existing Go credentials.' }
if ($data) {
    $stale = (Test-Path $failure) -or (([DateTimeOffset]::UtcNow - [DateTimeOffset]::Parse($data.updated)).TotalMinutes -gt 10)
    $mark = if ($stale) { ' !' } else { '' }
    $remaining = @{}
    $lines = @('OpenCode Go - quota remaining', ('Updated: ' + [DateTimeOffset]::Parse($data.updated).ToLocalTime().ToString('MM/dd HH:mm:ss')))
    if ($stale) { $lines += 'Cached data; refresh pending or failed' }
    foreach ($name in @('rolling', 'weekly', 'monthly')) {
        $value = $data.usage.$name
        $remaining[$name] = [int][Math]::Max(0, [Math]::Min(100, (100 - [double]$value.percent)))
        $reset = 'unknown'
        try { $reset = [DateTimeOffset]::Parse($value.resetsAt).ToLocalTime().ToString('MM/dd HH:mm') } catch {}
        $lines += "${name}: $($remaining[$name])% remaining; resets $reset"
    }
    $result.text = "Go${mark}  Month: $($remaining.monthly)%`n5h: $($remaining.rolling)%  7d: $($remaining.weekly)%"
    $result.alt = "OpenCode Go${mark} $($remaining.rolling)/$($remaining.weekly)/$($remaining.monthly)%"
    $result.tooltip = $lines -join "`n"
}
$result | ConvertTo-Json -Compress
