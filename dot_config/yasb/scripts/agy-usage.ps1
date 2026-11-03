param(
    [ValidateSet("status", "popup")]
    [string]$Action = "status",
    [switch]$CacheOnly
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$AgyPath = "C:\Users\kawasaki\AppData\Local\agy\bin\agy.exe"
if (-not (Test-Path $AgyPath)) {
    $cmd = Get-Command agy -ErrorAction SilentlyContinue
    if ($cmd) { $AgyPath = $cmd.Source }
}

$CacheFile = "C:\Users\kawasaki\.config\yasb\agy_usage_cache.json"

if ($Action -eq 'popup') {
    & (Join-Path $PSScriptRoot 'agy-quota-window.ps1') -CacheFile $CacheFile
    exit 0
}

function Format-RelativeTime {
    param([string]$IsoTime)
    if ([string]::IsNullOrWhiteSpace($IsoTime)) { return "" }
    try {
        $resetUtc = [DateTimeOffset]::Parse($IsoTime)
        $localStr = $resetUtc.ToLocalTime().ToString("MM/dd HH:mm")
        $diff = $resetUtc - [DateTimeOffset]::UtcNow
        if ($diff.TotalMinutes -le 0) {
            return "$localStr (refreshing)"
        }
        $days = [int][Math]::Floor($diff.TotalDays)
        $hours = $diff.Hours
        $mins = $diff.Minutes
        if ($days -gt 0) {
            return "$localStr (in ${days}d ${hours}h)"
        } elseif ($hours -gt 0) {
            return "$localStr (in ${hours}h ${mins}m)"
        } else {
            return "$localStr (in ${mins}m)"
        }
    } catch {
        return $IsoTime
    }
}

$rawJson = $null
$isStale = $false

$StateDir = Join-Path $env:LOCALAPPDATA "yasb-agy-usage"
$AttemptFile = Join-Path $StateDir "last-attempt.txt"
$FailureFile = Join-Path $StateDir "last-error.txt"

function Invoke-BoundedUsage {
    param(
        [string]$Executable,
        [string]$Arguments = '-p "/usage" --output-format json',
        [string]$WorkingDirectory,
        [int]$TimeoutSeconds = 10
    )
    $stdout = Join-Path $WorkingDirectory ([Guid]::NewGuid().ToString() + '.out')
    $stderr = $stdout + '.err'
    $process = $null
    try {
        $process = Start-Process -FilePath $Executable -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -ErrorAction Stop
        # Keep a handle so Windows PowerShell can retrieve the exit code after exit.
        $processHandle = $process.Handle
        try { $process.PriorityClass = 'BelowNormal' } catch {}
        $timer = [Diagnostics.Stopwatch]::StartNew()
        while (-not $process.WaitForExit(200)) {
            $process.Refresh()
            if ($timer.Elapsed.TotalSeconds -ge $TimeoutSeconds) { throw 'AGY refresh timed out' }
            if ($process.PrivateMemorySize64 -gt 512MB) { throw 'AGY memory limit exceeded (512 MB)' }
            foreach ($file in @($stdout, $stderr)) {
                if ((Get-Item -LiteralPath $file -ErrorAction SilentlyContinue).Length -gt 1MB) { throw 'AGY output limit exceeded' }
            }
        }
        $process.Refresh()
        if ($process.ExitCode -ne 0) { throw "AGY exited with code $($process.ExitCode)" }
        if ((Get-Item -LiteralPath $stdout).Length -gt 1MB) { throw 'AGY output limit exceeded' }
        return [IO.File]::ReadAllText($stdout, [Text.Encoding]::UTF8)
    } finally {
        if ($process) {
            if (-not $process.HasExited) {
                # Stop only our own process tree, never other user AGY sessions.
                & "$env:SystemRoot\System32\taskkill.exe" /PID $process.Id /T /F 2>$null | Out-Null
            }
            $process.Dispose()
        }
        Remove-Item -LiteralPath $stdout, $stderr -Force -ErrorAction SilentlyContinue
    }
}

$mutex = $null
$ownsMutex = $false
try {
    if ($Action -eq 'status' -and -not $CacheOnly -and (Test-Path $AgyPath)) {
        $mutex = New-Object Threading.Mutex($false, 'Local\YASB-AgyUsage-Refresh')
        try { $ownsMutex = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $ownsMutex = $true }
        if ($ownsMutex) {
            # Isolate CLI startup from the YASB project and its many theme files.
            New-Item -ItemType Directory -Path $StateDir -Force -ErrorAction Stop | Out-Null
            $cooldown = if (Test-Path $FailureFile) { 900 } else { 300 }
            $recent = (Test-Path $AttemptFile) -and (((Get-Date).ToUniversalTime() - (Get-Item $AttemptFile).LastWriteTimeUtc).TotalSeconds -lt $cooldown)
            if (-not $recent) {
                [IO.File]::WriteAllText($AttemptFile, [DateTimeOffset]::UtcNow.ToString('o'))
                $out = Invoke-BoundedUsage -Executable $AgyPath -WorkingDirectory $StateDir
                $jsonLine = $out -split "`r?`n" | Where-Object { $_ -match '^\s*\{.*\}\s*$' } | Select-Object -Last 1
                $parsed = $jsonLine | ConvertFrom-Json -ErrorAction Stop
                if ($parsed.status -ne 'SUCCESS' -or -not $parsed.command.data.groups) { throw 'AGY returned no valid quota data' }
                $tempCache = $CacheFile + '.tmp'
                [IO.File]::WriteAllText($tempCache, $jsonLine, (New-Object Text.UTF8Encoding($false)))
                if (Test-Path $CacheFile) { [IO.File]::Replace($tempCache, $CacheFile, ($CacheFile + '.previous')) }
                else { [IO.File]::Move($tempCache, $CacheFile) }
                $rawJson = $parsed
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

if (-not $rawJson -and (Test-Path $CacheFile)) {
    try {
        $rawJson = [System.IO.File]::ReadAllText($CacheFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
        $isStale = (Test-Path $FailureFile) -or (((Get-Date).ToUniversalTime() - (Get-Item $CacheFile).LastWriteTimeUtc).TotalSeconds -ge 300)
    } catch {}
}

if (-not $rawJson) {
    $fallback = @{
        text    = "AGY --%"
        wide    = "AGY`nQuota unavailable"
        alt     = "AGY Unavailable"
        tooltip = "Google Antigravity (agy) quota unavailable"
    }
    Write-Output ($fallback | ConvertTo-Json -Compress)
    exit 0
}

$bucketsById = @{}
$tooltipLines = @("Google Antigravity (agy) Quota Remaining")
if ($isStale) {
    $tooltipLines += "* Showing cached data (offline or refresh failed)"
}
$tooltipLines += "----------------------------------------"
if (Test-Path $CacheFile) {
    $tooltipLines += "Last updated: $((Get-Item $CacheFile).LastWriteTime.ToString('MM/dd HH:mm:ss'))"
}

foreach ($group in $rawJson.command.data.groups) {
    $tooltipLines += "[$($group.name)]"
    foreach ($b in $group.buckets) {
        $pct = [int][Math]::Round([double]$b.remaining_fraction * 100)
        $bucketsById[$b.id] = $pct
        $resetText = Format-RelativeTime -IsoTime $b.reset_time
        $tooltipLines += "  - $($b.name): ${pct}%  (Reset: $resetText)"
    }
}

$argonPct = if ($bucketsById.ContainsKey("gemini-argon-wtu-weekly")) { $bucketsById["gemini-argon-wtu-weekly"] } else { $null }
$gem5h    = if ($bucketsById.ContainsKey("gemini-5h")) { $bucketsById["gemini-5h"] } else { 100 }
$gem7d    = if ($bucketsById.ContainsKey("gemini-weekly")) { $bucketsById["gemini-weekly"] } else { 100 }
$gemMin   = [Math]::Min($gem5h, $gem7d)

$tp5h     = if ($bucketsById.ContainsKey("3p-5h")) { $bucketsById["3p-5h"] } else { 100 }
$tp7d     = if ($bucketsById.ContainsKey("3p-weekly")) { $bucketsById["3p-weekly"] } else { 100 }
$tpMin    = [Math]::Min($tp5h, $tp7d)

$staleMark = if ($isStale) { " !" } else { "" }
$claude5h = if ($bucketsById.ContainsKey('3p-5h')) { "${tp5h}%" } else { '--' }
$claude7d = if ($bucketsById.ContainsKey('3p-weekly')) { "${tp7d}%" } else { '--' }
$claudeLabel = "Claude/GPT 5h:${claude5h} 7d:${claude7d}"

if ($null -ne $argonPct) {
    $text = "AGY Argon:${argonPct}% Gem:${gemMin}% ${claudeLabel}${staleMark}"
    $alt  = "AGY A:${argonPct}% G:${gem5h}/${gem7d}% 3P:${tp5h}/${tp7d}%${staleMark}"
} else {
    $text = "AGY 5h:${gem5h}% 7d:${gem7d}% ${claudeLabel}${staleMark}"
    $alt  = "AGY G:${gem5h}/${gem7d}% 3P:${tp5h}/${tp7d}%${staleMark}"
}

$result = @{
    text    = $text
    wide    = $(if ($null -ne $argonPct) { "AGY${staleMark}  Argon:${argonPct}% Gem:${gemMin}%`nClaude/GPT 5h: ${claude5h}`nClaude/GPT 7d: ${claude7d}" } else { "AGY${staleMark}  Gem 5h:${gem5h}% 7d:${gem7d}%`nClaude/GPT 5h: ${claude5h}`nClaude/GPT 7d: ${claude7d}" })
    alt     = $alt
    tooltip = ($tooltipLines -join "`n")
}

Write-Output ($result | ConvertTo-Json -Compress)
