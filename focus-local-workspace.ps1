param(
    [int]$targetIndex
)

# Fetch GlazeWM states
$monitorsJson = glazewm query monitors | ConvertFrom-Json
$workspacesJson = glazewm query workspaces | ConvertFrom-Json

# Identify which monitor currently has focus
$focusedMonitor = $monitorsJson.data.monitors | Where-Object { $_.hasFocus -eq $true }

# Fallback: Identify by looking at which workspace has focus
if (-not $focusedMonitor) {
    $focusedWorkspace = $workspacesJson.data.workspaces | Where-Object { $_.hasFocus -eq $true }
    if ($focusedWorkspace) {
        $focusedMonitor = $monitorsJson.data.monitors | Where-Object { $_.id -eq $focusedWorkspace.parentId }
    }
}

if (-not $focusedMonitor) {
    exit
}

# Determine monitor index (0, 1, 2, or 3)
$monitorIndex = [array]::IndexOf($monitorsJson.data.monitors.id, $focusedMonitor.id)

if ($monitorIndex -eq -1) {
    exit
}

# Mapping: Monitor index -> Workspace names
$workspaceMapping = @(
    @('1', '2', '3', '4'),    # Monitor 0
    @('5', '6', '7'),         # Monitor 1
    @('8', '9', '10'),        # Monitor 2
    @('11', '12', '13')       # Monitor 3
)

if ($monitorIndex -lt $workspaceMapping.Length) {
    $monitorWorkspaces = $workspaceMapping[$monitorIndex]
    $mappedIndex = $targetIndex - 1
    if ($mappedIndex -ge 0 -and $mappedIndex -lt $monitorWorkspaces.Length) {
        $targetWorkspaceName = $monitorWorkspaces[$mappedIndex]
        glazewm command focus --workspace $targetWorkspaceName
    }
}
