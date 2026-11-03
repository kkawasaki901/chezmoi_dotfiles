$ErrorActionPreference = "Stop"

$RepoPath = "C:\Users\kawasaki\gitjournal"
$DriveDest = "gdrive:X_Screenshot"

$FailedDir = Join-Path $RepoPath "failed"
$JsonDir = Join-Path $RepoPath "oembed_json"

# repo外に一時退避する
$TempRoot = Join-Path $env:TEMP "gitjournal_failed_backup"
$TempFailedDir = Join-Path $TempRoot "failed"

Write-Host "=== 0. failed を一時退避 ==="

if (Test-Path $TempRoot) {
  Remove-Item -Path $TempRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

if (Test-Path $FailedDir) {
  Move-Item -Path $FailedDir -Destination $TempFailedDir -Force
  Write-Host "failed を退避しました: $TempFailedDir"
}
else {
  Write-Host "failed は存在しませんでした。"
}

Set-Location $RepoPath

Write-Host "=== 1. GitHub から最新状態を取得 ==="

git fetch origin
git reset --hard origin/main
git clean -fd

Write-Host "=== 2. failed を戻す ==="

if (Test-Path $TempFailedDir) {
  if (Test-Path $FailedDir) {
    # reset後にGit管理されたfailedが復活している場合、中身を統合する
    Get-ChildItem -Path $TempFailedDir -Force | ForEach-Object {
      $dest = Join-Path $FailedDir $_.Name

      if (Test-Path $dest) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $ext = [System.IO.Path]::GetExtension($_.Name)
        $dest = Join-Path $FailedDir "${baseName}_${stamp}${ext}"
      }

      Move-Item -Path $_.FullName -Destination $dest -Force
    }

    Remove-Item -Path $TempFailedDir -Recurse -Force
  }
  else {
    Move-Item -Path $TempFailedDir -Destination $FailedDir -Force
  }

  Write-Host "failed を戻しました: $FailedDir"
}

New-Item -ItemType Directory -Path $FailedDir -Force | Out-Null
New-Item -ItemType Directory -Path $JsonDir -Force | Out-Null

Write-Host "=== 3. .md から X URL を抽出して oEmbed JSON を取得 ==="

$TargetFiles = @()

# gitjournal直下の .md
$RootMdFiles = Get-ChildItem -Path $RepoPath -File -Filter "*.md" |
Where-Object {
  $_.FullName -notlike "$FailedDir*"
}

# failed内の .md
$FailedMdFiles = Get-ChildItem -Path $FailedDir -File -Filter "*.md" -ErrorAction SilentlyContinue

$TargetFiles += $RootMdFiles
$TargetFiles += $FailedMdFiles

foreach ($File in $TargetFiles) {
  Write-Host "Processing: $($File.FullName)"

  try {
    $content = Get-Content -Path $File.FullName -Raw -Encoding UTF8

    $match = [regex]::Match(
      $content,
      'https?://(?:www\.)?(?:x\.com|twitter\.com)/(?:i/status|[^/\s]+/status)/\d+'
    )

    if (-not $match.Success) {
      throw "X URL が見つかりません"
    }

    $tweetUrl = $match.Value
    Write-Host "  URL: $tweetUrl"

    $encodedUrl = [System.Uri]::EscapeDataString($tweetUrl)
    $apiUrl = "https://publish.twitter.com/oembed?url=$encodedUrl&omit_script=true"

    $json = Invoke-RestMethod -Uri $apiUrl -Method Get

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
    $jsonPath = Join-Path $JsonDir "$baseName.json"

    # 同名JSONがある場合は上書き
    $json |
    ConvertTo-Json -Depth 20 |
    Set-Content -Path $jsonPath -Encoding utf8

    Write-Host "  OK -> $jsonPath"

    # 成功した .md は削除
    Remove-Item -Path $File.FullName -Force
  }
  catch {
    Write-Host "  FAILED: $($_.Exception.Message)"

    # failed内のファイルならそのまま残す
    if ($File.DirectoryName -ne $FailedDir) {
      $dest = Join-Path $FailedDir $File.Name

      # 同名衝突対策
      if (Test-Path $dest) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
        $ext = [System.IO.Path]::GetExtension($File.Name)
        $dest = Join-Path $FailedDir "${baseName}_${stamp}${ext}"
      }

      Move-Item -Path $File.FullName -Destination $dest -Force
      Write-Host "  moved to failed: $dest"
    }
  }

  Start-Sleep -Milliseconds 500
}

Write-Host "=== 4. .git 以外を Google Drive に移動 ==="

rclone move . $DriveDest `
  --exclude ".git/**" `
  --exclude ".git"

Write-Host "=== 5. GitHub 上の最新状態を空にする ==="

git add -A

$status = git status --porcelain

if ([string]::IsNullOrWhiteSpace($status)) {
  Write-Host "変更がありません。commit / push せず終了します。"
  exit 0
}

git commit -m "Move contents to Google Drive and remove repository contents"
git push

Write-Host "完了しました。"