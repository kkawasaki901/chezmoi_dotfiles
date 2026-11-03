param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Uri
)

$ErrorActionPreference = 'Stop'

$parsed = [Uri]$Uri
if ($parsed.Scheme -ne 'nuopen') {
    throw "Unsupported URI scheme: $($parsed.Scheme)"
}

$query = [Web.HttpUtility]::ParseQueryString($parsed.Query)
$target = $query['path']
if ([string]::IsNullOrWhiteSpace($target)) {
    throw 'The nuopen URI does not contain a path.'
}

$resolved = Resolve-Path -LiteralPath $target
Start-Process -FilePath $resolved.Path
