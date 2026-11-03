# qutebrowser quickmark userscript for custom tags and titles
# Saves current page with custom tag and custom title: name url

$url = $env:QUTE_URL
$title = $env:QUTE_TITLE
$quickmarkFile = "C:\Users\kawasaki\AppData\Roaming\qutebrowser\config\quickmarks"

if (-not $url) {
    exit 1
}

# Ensure directory and file exists
if (-not (Test-Path $quickmarkFile)) {
    $dir = Split-Path $quickmarkFile
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    New-Item -ItemType File -Path $quickmarkFile -Force | Out-Null
}

$tags = @()
$displayTitle = $title

# Parse arguments (normalize spaces)
if ($args.Count -gt 0) {
    $rawArgsString = $args -join " "
    $normalizedArgsString = $rawArgsString -replace "　", " "
    # @() keeps a single result as an array; a bare pipeline collapses it to a
    # string, and string[0] returns only the first character
    $newArgs = @($normalizedArgsString -split "\s+" | Where-Object { $_ -ne "" })

    $customTitle = if ($newArgs -and $newArgs.Count -gt 0) { $newArgs[0] } else { $null }
    $tags = if ($newArgs -and $newArgs.Count -gt 1) { $newArgs[1..($newArgs.Count-1)] } else { @() }
    $displayTitle = if ($customTitle) { $customTitle } else { $title }
}

# Assemble tag prefix if multiple tags are provided
$tagPrefix = ""
if ($tags -and $tags.Count -gt 0) {
    $formattedTags = foreach ($t in $tags) {
        $clean = $t -replace '^\[|\]$', ''
        if ($clean) { "[$clean]" }
    }
    $tagPrefix = ($formattedTags -join " ") + " "
}

$formattedName = "${tagPrefix}${displayTitle}"

# Combine Name and URL (space separated, name first, url last)
$line = "$formattedName $url"

# Append to quickmarks file as UTF-8 without BOM
[System.IO.File]::AppendAllLines($quickmarkFile, [string[]]$line, [System.Text.UTF8Encoding]::new($false))

# Notify qutebrowser using FIFO and reload quickmarks instantly
if ($env:QUTE_FIFO) {
    $msg = "quickmarks-reload ;; message-info 'Quickmarked: $formattedName'"
    [System.IO.File]::WriteAllText($env:QUTE_FIFO, $msg, [System.Text.UTF8Encoding]::new($false))
}
