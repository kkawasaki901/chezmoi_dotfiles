param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Target
)

$ErrorActionPreference = 'Stop'

# URLs are passed directly to Windows ShellExecute.
if ($Target -match '^[A-Za-z][A-Za-z0-9+.-]*://') {
    Start-Process -FilePath $Target
    exit 0
}

# Resolve filesystem paths without URL-encoding non-ASCII characters.
$resolved = Resolve-Path -LiteralPath $Target
Start-Process -FilePath $resolved.Path
