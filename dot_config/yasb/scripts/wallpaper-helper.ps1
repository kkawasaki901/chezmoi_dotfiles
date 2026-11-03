param(
    [ValidateSet("fetch", "select-folder", "apply-online")]
    [string]$Action = "fetch",
    [ValidateSet("all", "bing", "wallhaven", "picsum")]
    [string]$Source = "all"
)

$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ConfigFile = Join-Path $env:USERPROFILE ".config\yasb\config.yaml"
$DefaultWallpaperDir = Join-Path $env:USERPROFILE "Pictures\Wallpapers"
$OnlineWallpaperDir = Join-Path $DefaultWallpaperDir "Online"

if (-not (Test-Path $DefaultWallpaperDir)) {
    New-Item -ItemType Directory -Force -Path $DefaultWallpaperDir | Out-Null
}
if (-not (Test-Path $OnlineWallpaperDir)) {
    New-Item -ItemType Directory -Force -Path $OnlineWallpaperDir | Out-Null
}

function Get-WallpaperRoots {
    param([string]$Selected, [string]$Online)
    $selectedRoot = [IO.Path]::GetFullPath($Selected).TrimEnd('\')
    $onlineRoot = [IO.Path]::GetFullPath($Online).TrimEnd('\')
    $comparison = [StringComparison]::OrdinalIgnoreCase
    if ($onlineRoot.Equals($selectedRoot, $comparison) -or $onlineRoot.StartsWith($selectedRoot + '\', $comparison)) {
        return @($selectedRoot)
    }
    if ($selectedRoot.StartsWith($onlineRoot + '\', $comparison)) {
        return @($onlineRoot)
    }
    return @($selectedRoot, $onlineRoot)
}

function Set-DesktopWallpaper {
    param([string]$ImagePath)
    if (-not (Test-Path $ImagePath)) { return }
    $code = @'
using System;
using System.Runtime.InteropServices;
public class WallpaperSetter {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void Set(string path) {
        SystemParametersInfo(20, 0, path, 0x01 | 0x02);
    }
}
'@
    Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue
    [WallpaperSetter]::Set((Resolve-Path $ImagePath).Path)
}

function Fetch-BingWallpapers {
    try {
        $url = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=5&mkt=ja-JP"
        $resp = Invoke-RestMethod -Uri $url -TimeoutSec 15
        $downloaded = @()
        foreach ($img in $resp.images) {
            $imgUrl = "https://www.bing.com" + ($img.url -replace "1920x1080", "UHD")
            $safeName = "bing_" + $img.startdate + ".jpg"
            $dest = Join-Path $OnlineWallpaperDir $safeName
            if (-not (Test-Path $dest)) {
                try {
                    Invoke-WebRequest -Uri $imgUrl -OutFile $dest -TimeoutSec 20 -UseBasicParsing
                } catch {
                    $fallbackUrl = "https://www.bing.com" + $img.url
                    Invoke-WebRequest -Uri $fallbackUrl -OutFile $dest -TimeoutSec 20 -UseBasicParsing
                }
            }
            if (Test-Path $dest) { $downloaded += $dest }
        }
        return $downloaded
    } catch {
        return @()
    }
}

function Fetch-WallhavenWallpapers {
    try {
        $seed = -join ((65..90) + (97..122) | Get-Random -Count 6 | ForEach-Object {[char]$_})
        $topic = @("landscape", "nature", "scenic", "minimal", "cyberpunk", "mountains") | Get-Random
        $url = "https://wallhaven.cc/api/v1/search?q=$topic&categories=110&purity=100&atleast=2560x1440&ratios=16x9,16x10&sorting=random&seed=$seed"
        $resp = Invoke-RestMethod -Uri $url -TimeoutSec 15
        $downloaded = @()
        $items = $resp.data | Select-Object -First 2
        foreach ($item in $items) {
            $ext = [System.IO.Path]::GetExtension($item.path)
            if (-not $ext) { $ext = ".jpg" }
            $dest = Join-Path $OnlineWallpaperDir ("wallhaven_" + $item.id + $ext)
            if (-not (Test-Path $dest)) {
                Invoke-WebRequest -Uri $item.path -OutFile $dest -TimeoutSec 25 -UseBasicParsing
            }
            if (Test-Path $dest) { $downloaded += $dest }
        }
        return $downloaded
    } catch {
        return @()
    }
}

function Fetch-PicsumWallpaper {
    try {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $dest = Join-Path $OnlineWallpaperDir ("unsplash_picsum_$stamp.jpg")
        Invoke-WebRequest -Uri "https://picsum.photos/3840/2160" -OutFile $dest -TimeoutSec 20 -UseBasicParsing
        if (Test-Path $dest) { return @($dest) }
    } catch {}
    return @()
}

function Cleanup-OldOnlineWallpapers {
    $files = Get-ChildItem -Path $OnlineWallpaperDir -File | Sort-Object LastWriteTime -Descending
    if ($files.Count -gt 40) {
        $files | Select-Object -Skip 40 | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

if ($Action -eq "fetch") {
    $results = @()
    if ($Source -in @("all", "bing")) {
        $results += Fetch-BingWallpapers
    }
    if ($Source -in @("all", "wallhaven")) {
        $results += Fetch-WallhavenWallpapers
    }
    if ($results.Count -eq 0 -or $Source -eq "picsum") {
        $results += Fetch-PicsumWallpaper
    }
    Cleanup-OldOnlineWallpapers
    $total = (Get-ChildItem -Path $OnlineWallpaperDir -File -ErrorAction SilentlyContinue).Count
    $out = @{
        text = "Online ($total)"
        tooltip = "Online Wallpapers: $total cached`nLeft-click: Fetch & Apply random online wallpaper`nMiddle-click: Open Wallpapers folder`nRight-click: Select custom wallpaper folder"
    }
    $out | ConvertTo-Json -Compress
    exit 0
}

if ($Action -eq "apply-online") {
    $newFiles = @()
    $newFiles += Fetch-WallhavenWallpapers
    if ($newFiles.Count -eq 0) {
        $newFiles += Fetch-BingWallpapers
    }
    if ($newFiles.Count -eq 0) {
        $newFiles += Fetch-PicsumWallpaper
    }
    Cleanup-OldOnlineWallpapers
    $target = $null
    if ($newFiles.Count -gt 0) {
        $target = $newFiles | Get-Random
    } else {
        $all = Get-ChildItem -Path $OnlineWallpaperDir -File -ErrorAction SilentlyContinue
        if ($all.Count -gt 0) { $target = ($all | Get-Random).FullName }
    }
    if ($target) {
        Set-DesktopWallpaper -ImagePath $target
    }
    exit 0
}

if ($Action -eq "select-folder") {
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = "Select custom wallpaper folder for YASB (Online wallpapers folder is also kept)"
    $dialog.ShowNewFolderButton = $true
    if (Test-Path $DefaultWallpaperDir) {
        $dialog.SelectedPath = $DefaultWallpaperDir
    }
    $form = New-Object System.Windows.Forms.Form
    $form.TopMost = $true
    $result = $dialog.ShowDialog($form)
    if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $dialog.SelectedPath) {
        $selected = $dialog.SelectedPath
        if (Test-Path $ConfigFile) {
            $raw = [System.IO.File]::ReadAllText($ConfigFile, [System.Text.Encoding]::UTF8)
            $rootLines = @(Get-WallpaperRoots -Selected $selected -Online $OnlineWallpaperDir | ForEach-Object {
                $escapedRoot = $_.Replace('\', '\\')
                '        - "' + $escapedRoot + '"'
            })
            $replacementBlock = "      image_path:`r`n" + ($rootLines -join "`r`n")
            $pattern = '(?m)^      image_path:\r?\n(?:        - ".*?"\r?\n)+'
            if ($raw -match $pattern) {
                $updated = [regex]::Replace($raw, $pattern, ($replacementBlock + "`r`n"))
                [System.IO.File]::WriteAllText($ConfigFile, $updated, (New-Object System.Text.UTF8Encoding($false)))
            }
        }
        $imgs = Get-ChildItem -Path $selected -Include *.jpg,*.jpeg,*.png,*.bmp,*.webp -Recurse -File -ErrorAction SilentlyContinue
        if ($imgs.Count -gt 0) {
            $pick = ($imgs | Get-Random).FullName
            Set-DesktopWallpaper -ImagePath $pick
        }
    }
    exit 0
}
