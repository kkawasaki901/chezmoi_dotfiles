param(
    [ValidateSet("status")]
    [string]$Action = "status",
    [switch]$CacheOnly
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ClaudeConfigDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }
$CredFile = Join-Path $ClaudeConfigDir ".credentials.json"
$CacheFile = "C:\Users\kawasaki\.config\yasb\claude_usage_cache.json"

$StateDir = Join-Path $env:LOCALAPPDATA "yasb-claude-usage"
$AttemptFile = Join-Path $StateDir "last-attempt.txt"
$FailureFile = Join-Path $StateDir "last-error.txt"

function Format-RelativeTime {
    param([string]$IsoTime)
    if ([string]::IsNullOrWhiteSpace($IsoTime)) { return "" }
    try {
        $resetUtc = [DateTimeOffset]::Parse($IsoTime)
        $localStr = $resetUtc.ToLocalTime().ToString("MM/dd HH:mm")
        $diff = $resetUtc - [DateTimeOffset]::UtcNow
        if ($diff.TotalMinutes -le 0) { return "$localStr" }
        $days = [int][Math]::Floor($diff.TotalDays)
        $hours = $diff.Hours
        $mins = $diff.Minutes
        if ($days -gt 0) {
            return "$localStr (あと${days}d ${hours}h)"
        } elseif ($hours -gt 0) {
            return "$localStr (あと${hours}h ${mins}m)"
        } else {
            return "$localStr (あと${mins}m)"
        }
    } catch {
        return $IsoTime
    }
}

$usage = $null
$isStale = $false

$mutex = $null
$ownsMutex = $false
try {
    if ($Action -eq 'status' -and -not $CacheOnly -and (Test-Path $CredFile)) {
        # Prevent concurrent refreshes from multiple monitors / yasb reloads piling up network calls.
        $mutex = New-Object Threading.Mutex($false, 'Local\YASB-ClaudeUsage-Refresh')
        try { $ownsMutex = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $ownsMutex = $true }
        if ($ownsMutex) {
            New-Item -ItemType Directory -Path $StateDir -Force -ErrorAction Stop | Out-Null
            $cooldown = if (Test-Path $FailureFile) { 900 } else { 300 }
            $recent = (Test-Path $AttemptFile) -and (((Get-Date).ToUniversalTime() - (Get-Item $AttemptFile).LastWriteTimeUtc).TotalSeconds -lt $cooldown)
            if (-not $recent) {
                [IO.File]::WriteAllText($AttemptFile, [DateTimeOffset]::UtcNow.ToString('o'))
                $cred = Get-Content -Path $CredFile -Raw -Encoding UTF8 | ConvertFrom-Json
                $token = $cred.claudeAiOauth.accessToken
                if (-not $token) { throw 'Claude OAuth token not found' }
                $resp = Invoke-RestMethod -Method Get `
                    -Uri "https://api.anthropic.com/api/oauth/usage" `
                    -Headers @{
                        "Authorization" = "Bearer $token"
                        "anthropic-beta" = "oauth-2025-04-20"
                    } `
                    -TimeoutSec 10 `
                    -ErrorAction Stop
                if (-not $resp -or $null -eq $resp.five_hour -or $null -eq $resp.seven_day) { throw 'Claude usage API returned no data' }
                $jsonLine = $resp | ConvertTo-Json -Depth 10 -Compress
                $tempCache = $CacheFile + '.tmp'
                [IO.File]::WriteAllText($tempCache, $jsonLine, (New-Object Text.UTF8Encoding($false)))
                if (Test-Path $CacheFile) { [IO.File]::Replace($tempCache, $CacheFile, ($CacheFile + '.previous')) }
                else { [IO.File]::Move($tempCache, $CacheFile) }
                $usage = $resp
                Remove-Item -LiteralPath $FailureFile -Force -ErrorAction SilentlyContinue
            }
        }
    }
} catch {
    if (Test-Path $StateDir) {
        [IO.File]::WriteAllText($FailureFile, "$(Get-Date -Format o) $($_.Exception.Message)")
    }
} finally {
    if ($ownsMutex) { $mutex.ReleaseMutex() }
    if ($mutex) { $mutex.Dispose() }
}

if (-not $usage -and (Test-Path $CacheFile)) {
    try {
        $usage = Get-Content -Path $CacheFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $isStale = (Test-Path $FailureFile) -or (((Get-Date).ToUniversalTime() - (Get-Item $CacheFile).LastWriteTimeUtc).TotalSeconds -ge 300)
    } catch {}
}

if (-not $usage) {
    $fallback = @{
        five_remaining  = "--"
        seven_remaining = "--"
        text    = "--%"
        tooltip = "Claude の使用量を取得できませんでした`n(未ログイン、または .credentials.json が見つかりません)"
    }
    Write-Output ($fallback | ConvertTo-Json -Compress)
    exit 0
}

$fiveUtil = [double]$usage.five_hour.utilization
$sevenUtil = [double]$usage.seven_day.utilization
$fiveRem = [int][Math]::Round([Math]::Max(0.0, [Math]::Min(100.0, 100.0 - $fiveUtil)))
$sevenRem = [int][Math]::Round([Math]::Max(0.0, [Math]::Min(100.0, 100.0 - $sevenUtil)))
$fiveResetText = Format-RelativeTime -IsoTime $usage.five_hour.resets_at
$sevenResetText = Format-RelativeTime -IsoTime $usage.seven_day.resets_at

$staleMark = if ($isStale) { " !" } else { "" }

$text = "5h:${fiveRem}% 7d:${sevenRem}%${staleMark}"

$tooltipLines = @(
    "Claude Usage Remaining"
    "----------------------------------------"
)
if (Test-Path $CacheFile) {
    $tooltipLines += "Last updated: $((Get-Item $CacheFile).LastWriteTime.ToString('MM/dd HH:mm:ss'))"
}
$tooltipLines += "5h remaining:  ${fiveRem}%  (Reset: $fiveResetText)"
$tooltipLines += "7d remaining:  ${sevenRem}%  (Reset: $sevenResetText)"
if ($isStale) {
    $tooltipLines += "* キャッシュ表示 (取得失敗・オフライン)"
}

$result = @{
    five_remaining  = $fiveRem
    seven_remaining = $sevenRem
    five_reset      = $fiveResetText
    seven_reset     = $sevenResetText
    text    = $text
    tooltip = ($tooltipLines -join "`n")
}

Write-Output ($result | ConvertTo-Json -Compress)
