# qutebrowser userscript for custom H2 markdown yank formatting
# Copies current page title as "## Title" and URL on the next line to the clipboard

$url = $env:QUTE_URL
$title = $env:QUTE_TITLE

if (-not $url) {
    exit 1
}

# Format text with CRLF newline
$text = "## $title`r`n$url"

# Set text to clipboard robustly using Windows Forms API
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Clipboard]::SetText($text)

# Notify qutebrowser via FIFO
if ($env:QUTE_FIFO) {
    $msg = "message-info 'Yanked to clipboard: ## Title + URL'"
    [System.IO.File]::WriteAllText($env:QUTE_FIFO, $msg, [System.Text.UTF8Encoding]::new($false))
}
