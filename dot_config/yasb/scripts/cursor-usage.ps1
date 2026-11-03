param(
    [ValidateSet("status")]
    [string]$Action = "status",
    [switch]$CacheOnly
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$AuthFile = Join-Path $env:APPDATA "Cursor\auth.json"
$CacheFile = "C:\Users\kawasaki\.config\yasb\cursor_usage_cache.json"

$StateDir = Join-Path $env:LOCALAPPDATA "yasb-cursor-usage"
$AttemptFile = Join-Path $StateDir "last-attempt.txt"
$FailureFile = Join-Path $StateDir "last-error.txt"

function Format-ResetTime {
    param([string]$EpochMs)
    if ([string]::IsNullOrWhiteSpace($EpochMs)) { return "" }
    try {
        $resetUtc = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$EpochMs)
        $localStr = $resetUtc.ToLocalTime().ToString("MM/dd HH:mm")
        $diff = $resetUtc - [DateTimeOffset]::UtcNow
        if ($diff.TotalMinutes -le 0) { return "$localStr" }
        $days = [int][Math]::Floor($diff.TotalDays)
        $hours = $diff.Hours
        if ($days -gt 0) {
            return "$localStr (あと${days}d ${hours}h)"
        } else {
            return "$localStr (あと${hours}h)"
        }
    } catch {
        return $EpochMs
    }
}

$usage = $null
$isStale = $false

$mutex = $null
$ownsMutex = $false
try {
    if ($Action -eq 'status' -and -not $CacheOnly -and (Test-Path $AuthFile)) {
        # Prevent concurrent refreshes from multiple monitors / yasb reloads piling up network calls.
        $mutex = New-Object Threading.Mutex($false, 'Local\YASB-CursorUsage-Refresh')
        try { $ownsMutex = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $ownsMutex = $true }
        if ($ownsMutex) {
            New-Item -ItemType Directory -Path $StateDir -Force -ErrorAction Stop | Out-Null
            $cooldown = if (Test-Path $FailureFile) { 900 } else { 300 }
            $recent = (Test-Path $AttemptFile) -and (((Get-Date).ToUniversalTime() - (Get-Item $AttemptFile).LastWriteTimeUtc).TotalSeconds -lt $cooldown)
            if (-not $recent) {
                [IO.File]::WriteAllText($AttemptFile, [DateTimeOffset]::UtcNow.ToString('o'))
                $auth = Get-Content -Path $AuthFile -Raw -Encoding UTF8 | ConvertFrom-Json
                $token = $auth.accessToken
                if (-not $token) { throw 'Cursor auth token not found' }
                $resp = Invoke-RestMethod -Method Post `
                    -Uri "https://api2.cursor.sh/aiserver.v1.DashboardService/GetCurrentPeriodUsage" `
                    -Headers @{
                        "Authorization" = "Bearer $token"
                        "Connect-Protocol-Version" = "1"
                    } `
                    -ContentType "application/json" `
                    -Body "{}" `
                    -TimeoutSec 10 `
                    -ErrorAction Stop
                if (-not $resp) { throw 'Cursor API returned empty response' }
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
        text    = "Cursor --%"
        alt     = "Cursor Unavailable"
        tooltip = "Cursor の使用率を取得できませんでした`n(未ログイン、または auth.json が見つかりません)"
    }
    Write-Output ($fallback | ConvertTo-Json -Compress)
    exit 0
}

$totalUsedRaw = [double]$usage.planUsage.totalPercentUsed
$autoUsedRaw = [double]$usage.planUsage.autoPercentUsed
$apiUsedRaw = [double]$usage.planUsage.apiPercentUsed
$totalPct = [int][Math]::Round([Math]::Max(0.0, [Math]::Min(100.0, 100.0 - $totalUsedRaw)))
$autoPct = [int][Math]::Round([Math]::Max(0.0, [Math]::Min(100.0, 100.0 - $autoUsedRaw)))
$apiPct = [int][Math]::Round([Math]::Max(0.0, [Math]::Min(100.0, 100.0 - $apiUsedRaw)))
$resetText = Format-ResetTime -EpochMs $usage.billingCycleEnd

$staleMark = if ($isStale) { " !" } else { "" }

$text = "Cursor:${totalPct}%${staleMark}"
$alt = "Auto:${autoPct}% API:${apiPct}%${staleMark}"

$tooltipLines = @(
    "Cursor Usage Remaining"
    "----------------------------------------"
)
if (Test-Path $CacheFile) {
    $tooltipLines += "Last updated: $((Get-Item $CacheFile).LastWriteTime.ToString('MM/dd HH:mm:ss'))"
}
$tooltipLines += "Total remaining: ${totalPct}%"
$tooltipLines += "Auto remaining:  ${autoPct}%"
$tooltipLines += "API remaining:   ${apiPct}%"
$tooltipLines += "Reset: $resetText"
if ($isStale) {
    $tooltipLines += "* キャッシュ表示 (取得失敗・オフライン)"
}
if ($usage.displayMessage) {
    $tooltipLines += "----------------------------------------"
    $tooltipLines += "$($usage.displayMessage)"
}

$result = @{
    text    = $text
    alt     = $alt
    tooltip = ($tooltipLines -join "`n")
}

Write-Output ($result | ConvertTo-Json -Compress)
