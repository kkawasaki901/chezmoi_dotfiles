# Heal GlazeWM after sleep/display reconnects corrupt its monitor topology.
# A corrupted topology can reject workspace moves with "No displayed workspace",
# so restart only when all physical monitors are stable and placement is wrong.
$ErrorActionPreference = 'Stop'
$glazewm = "$env:USERPROFILE\scoop\shims\glazewm.exe"
$logPath = "$env:USERPROFILE\.glzr\glazewm\restore-workspaces.log"

$workspaceTargets = @{
    '1' = 'SKG3215'; '2' = 'SKG3215'; '3' = 'SKG3215'; '4' = 'SKG3215'
    '5' = 'GAM2200'; '6' = 'GAM2200'; '7' = 'GAM2200'
    '8' = 'YCT229A'; '9' = 'YCT229A'; '10' = 'YCT229A'
    '11' = 'GSM5C5B'; '12' = 'GSM5C5B'; '13' = 'GSM5C5B'
}
$expectedHardware = @($workspaceTargets.Values | Sort-Object -Unique)

function Write-RepairLog([string]$message) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $message" | Add-Content -LiteralPath $logPath -Encoding utf8
}

function Show-RepairNotification([string]$message) {
    & "$env:SystemRoot\System32\msg.exe" $env:USERNAME /TIME:5 "GlazeWM: $message" 2>$null | Out-Null
}

function Get-Monitors {
    try {
        $json = & $glazewm query monitors 2>$null | ConvertFrom-Json
        if ($json.success) { return @($json.data.monitors) }
    } catch {}
    return @()
}

function Get-Windows {
    try {
        $json = & $glazewm query windows 2>$null | ConvertFrom-Json
        if ($json.success) { return @($json.data.windows) }
    } catch {}
    return @()
}

function Test-AllMonitorsReady($monitors) {
    if (@($monitors).Count -ne $expectedHardware.Count) { return $false }
    $actual = @($monitors.hardwareId | Sort-Object -Unique)
    return @($expectedHardware | Where-Object { $_ -notin $actual }).Count -eq 0
}

function Get-MisplacedCount($monitors) {
    $count = 0
    foreach ($monitor in $monitors) {
        foreach ($workspace in @($monitor.children | Where-Object type -eq 'workspace')) {
            $target = $workspaceTargets[[string]$workspace.name]
            if ($target -and $monitor.hardwareId -ne $target) { $count++ }
        }
    }
    return $count
}

# Displays reconnect in stages. Require three identical snapshots before acting.
$stableCount = 0
$lastSignature = ''
$monitors = @()
for ($attempt = 0; $attempt -lt 60; $attempt++) {
    $monitors = Get-Monitors
    if (Test-AllMonitorsReady $monitors) {
        $signature = (($monitors | Sort-Object hardwareId | ForEach-Object {
            "$($_.hardwareId):$($_.x),$($_.y),$($_.width)x$($_.height)"
        }) -join '|')
        $stableCount = if ($signature -eq $lastSignature) { $stableCount + 1 } else { 1 }
        $lastSignature = $signature
        if ($stableCount -ge 3) { break }
    } else {
        $stableCount = 0
        $lastSignature = ''
    }
    Start-Sleep -Seconds 2
}
if ($stableCount -lt 3) {
    Write-RepairLog 'SKIP monitors did not become stable within 120 seconds'
    Show-RepairNotification 'Monitors are not stable. Repair was cancelled.'
    exit 1
}

$misplaced = Get-MisplacedCount $monitors
if ($misplaced -eq 0) {
    Write-RepairLog 'OK workspace placement is already correct'
    Show-RepairNotification 'Workspace placement is already correct.'
    exit 0
}

Write-RepairLog "RESTART misplaced=$misplaced"

# Remember native window handles that were not minimized before restart.
# GlazeWM can incorrectly adopt some Windows Terminal windows as minimized.
$restoreHandles = @(
    Get-Windows |
        Where-Object { $_.state.type -ne 'minimized' } |
        ForEach-Object { [long]$_.handle }
)

# Graceful exit runs configured shutdown commands. Force termination is only a
# fallback for the corrupted IPC state seen after display reconnects.
try { & $glazewm command wm-exit 2>$null | Out-Null } catch {}
Start-Sleep -Seconds 2
$remainingProcesses = Get-Process glazewm -ErrorAction SilentlyContinue
if ($remainingProcesses) { $remainingProcesses | Stop-Process -Force }
Start-Sleep -Milliseconds 700
Start-Process -FilePath $glazewm -WindowStyle Hidden

# Verify the restarted instance rebuilt all configured workspace bindings.
for ($attempt = 0; $attempt -lt 30; $attempt++) {
    Start-Sleep -Seconds 1
    $monitors = Get-Monitors
    $allMonitorsReady = Test-AllMonitorsReady $monitors
    $remainingMisplaced = Get-MisplacedCount $monitors
    if ($allMonitorsReady -and $remainingMisplaced -eq 0) {
        $restoredWindows = 0
        foreach ($window in @(Get-Windows | Where-Object { $_.state.type -eq 'minimized' })) {
            if ([long]$window.handle -in $restoreHandles) {
                & $glazewm command --id $window.id toggle-minimized 2>$null | Out-Null
                $restoredWindows++
            }
        }
        Write-RepairLog 'OK workspace placement restored'
        if ($restoredWindows -gt 0) { Write-RepairLog "OK unminimized=$restoredWindows" }
        Show-RepairNotification 'Workspace placement was repaired.'
        exit 0
    }
}
Write-RepairLog "FAILED remaining=$(Get-MisplacedCount $monitors)"
Show-RepairNotification 'Repair failed. Check restore-workspaces.log.'
exit 2
