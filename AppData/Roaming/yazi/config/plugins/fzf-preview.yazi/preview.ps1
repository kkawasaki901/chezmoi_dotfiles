param(
    [Parameter(Position = 0)]
    [string]$Path
)

if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
    exit 0
}

$item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
if ($null -eq $item) {
    exit 0
}

if ($item.PSIsContainer) {
    & eza.exe --tree --level=2 --color=always --group-directories-first --icons=always -- $item.FullName
    exit $LASTEXITCODE
}

& bat.exe --color=always --style=numbers,changes --line-range=:500 -- $item.FullName
if ($LASTEXITCODE -ne 0) {
    Get-Content -LiteralPath $item.FullName -TotalCount 500 -ErrorAction SilentlyContinue
}
