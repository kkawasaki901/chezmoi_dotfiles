<#
.SYNOPSIS
    ローカルディレクトリが存在しなくなった Basic Memory プロジェクトを登録から削除する。

.DESCRIPTION
    Basic Memory の設定ファイル (既定: %USERPROFILE%\.basic-memory\config.json) を直接読み込み、
    登録済みプロジェクトごとにローカルパスが実際に存在するか確認する。
    存在しないプロジェクトを一覧表示し、-Apply を指定した場合のみ
    `basic-memory project remove <name>` で登録を削除する。

    注意: `basic-memory project list` / `project list --json` を実行すると、
    Basic Memory 側が各プロジェクトのディレクトリを自動的に再作成してしまう
    (存在確認のために list を呼ぶと、呼んだ瞬間に対象が復活してしまう)。
    そのため本スクリプトは basic-memory コマンドを一切呼ばずに config.json を
    直接読み、確定した「消滅済みプロジェクト一覧」に対してのみ
    `project remove` を実行する。

.PARAMETER Apply
    実際に削除を実行する。指定しない場合はドライラン(一覧表示のみ)。

.PARAMETER IncludeDefault
    デフォルトプロジェクト (config.json の default_project) も削除対象に含める。

.PARAMETER DeleteNotes
    `basic-memory project remove` に --delete-notes を付けて実行する。
    (ディレクトリが既に無い前提のスクリプトなので通常は不要)

.PARAMETER ConfigPath
    Basic Memory の config.json のパス。既定値は %USERPROFILE%\.basic-memory\config.json。

.EXAMPLE
    .\remove-stale-basicmemory-projects.ps1
    削除対象を一覧表示するだけ(何も削除しない)。

.EXAMPLE
    .\remove-stale-basicmemory-projects.ps1 -Apply
    ディレクトリが存在しないプロジェクトを実際に登録から削除する。
#>

param(
    [switch]$Apply,
    [switch]$IncludeDefault,
    [switch]$DeleteNotes,
    [string]$ConfigPath = (Join-Path $env:USERPROFILE ".basic-memory\config.json")
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command basic-memory -ErrorAction SilentlyContinue)) {
    Write-Error "basic-memory コマンドが見つかりません。インストール状況を確認してください。"
    exit 1
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-Error "Basic Memory の設定ファイルが見つかりません: $ConfigPath"
    exit 1
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$projectEntries = $config.projects.PSObject.Properties
$defaultProject = $config.default_project

if (-not $projectEntries -or $projectEntries.Count -eq 0) {
    Write-Host "登録されている Basic Memory プロジェクトがありません。"
    exit 0
}

$staleProjects = @()
$skippedDefault = @()

foreach ($entry in $projectEntries) {
    $name = $entry.Name
    $path = $entry.Value.path
    $mode = $entry.Value.mode

    if ($mode -ne "local" -or [string]::IsNullOrWhiteSpace($path)) {
        continue
    }

    if (-not (Test-Path -LiteralPath $path)) {
        if ($name -eq $defaultProject -and -not $IncludeDefault) {
            $skippedDefault += [pscustomobject]@{ Name = $name; Path = $path }
        }
        else {
            $staleProjects += [pscustomobject]@{ Name = $name; Path = $path }
        }
    }
}

if ($skippedDefault.Count -gt 0) {
    Write-Host "`n[注意] 以下はデフォルトプロジェクトのためディレクトリが無くてもスキップしました (-IncludeDefault で対象に含められます):"
    foreach ($p in $skippedDefault) {
        Write-Host "  - $($p.Name)  ($($p.Path))"
    }
}

if ($staleProjects.Count -eq 0) {
    Write-Host "`nディレクトリが存在しないプロジェクトはありませんでした。"
    exit 0
}

Write-Host "`n以下のプロジェクトはローカルディレクトリが存在しません:"
foreach ($p in $staleProjects) {
    Write-Host "  - $($p.Name)  ($($p.Path))"
}

if (-not $Apply) {
    Write-Host "`nドライランのため削除は実行していません。実際に削除するには -Apply を付けて再実行してください。"
    exit 0
}

Write-Host "`n削除を実行します..."
foreach ($p in $staleProjects) {
    $removeArgs = @("project", "remove", $p.Name)
    if ($DeleteNotes) {
        $removeArgs += "--delete-notes"
    }

    $result = & basic-memory @removeArgs 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  削除しました: $($p.Name)"
    }
    else {
        Write-Warning "  削除に失敗しました: $($p.Name)`n$result"
    }
}

Write-Host "`n完了しました。"
