
echo "from kawasaki\Greenshot to googledrive\X_Screenshot"

rclone lsf "gdrive:X_Screenshot" > $null
if ($LASTEXITCODE -eq 0) {
    rclone move "$HOME\Greenshot" "gdrive:X_Screenshot" --progress --delete-empty-src-dirs
}
else {
    Write-Host "Google Driveに接続できないので、移動・削除はしません。"
}