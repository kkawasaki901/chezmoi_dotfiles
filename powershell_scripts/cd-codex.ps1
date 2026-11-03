$BaseDir = "C:\Users\kawasaki\codex"
$base = Resolve-Path $BaseDir -ErrorAction SilentlyContinue
if ($null -eq $base) {
    Write-Host "ディレクトリが見つかりません: $BaseDir"
    return
}
$basePath = $base.Path
$selected = Get-ChildItem -Path $basePath -Directory -Recurse |
    ForEach-Object {
        $relative = $_.FullName.Substring($basePath.Length).TrimStart('\')
        "$relative`t$($_.FullName)"
    } |
    fzf --delimiter "`t" --with-nth 1 --prompt="cd> " --height=100% --reverse
if ([string]::IsNullOrWhiteSpace($selected)) {
    return
}
$path = ($selected -split "`t", 2)[1]
Set-Location $path
