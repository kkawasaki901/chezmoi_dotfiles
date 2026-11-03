# push-current-project.ps1

$Org = "kawasaki-software"   # ← 自分のOrganization名に変える
$Visibility = "--private" # 公開したいなら "--public"

$ProjectPath = Get-Location
$RepoName = Split-Path $ProjectPath -Leaf

Write-Host "Project: $ProjectPath" -ForegroundColor Cyan
Write-Host "Repo:    $Org/$RepoName" -ForegroundColor Cyan

# Git未初期化なら init
if (-not (Test-Path ".git")) {
    git init
}

# mainブランチにする
git branch -M main 2>$null

# .gitignore がなければ最低限作る
if (-not (Test-Path ".gitignore")) {
    @"
node_modules/
dist/
build/
target/
.env
.DS_Store
"@ | Set-Content ".gitignore" -Encoding UTF8
}

# 変更をコミット
git add .

$status = git status --porcelain
if ($status) {
    git commit -m "Initial commit"
}
else {
    Write-Host "No changes to commit" -ForegroundColor Yellow
}

# 既存originがあればOrganization向けに変更、なければ作成
$RemoteUrl = "https://github.com/$Org/$RepoName.git"

$ExistingOrigin = git remote get-url origin 2>$null

if ($ExistingOrigin) {
    Write-Host "origin already exists: $ExistingOrigin" -ForegroundColor Yellow
    git remote set-url origin $RemoteUrl
}
else {
    git remote add origin $RemoteUrl
}

# GitHub上にリポジトリを作成
# すでに存在する場合はエラーになるが、そのままpushへ進む
gh repo create "$Org/$RepoName" $Visibility --source . --remote origin 2>$null

# push
git push -u origin main

Write-Host "Done: https://github.com/$Org/$RepoName" -ForegroundColor Green