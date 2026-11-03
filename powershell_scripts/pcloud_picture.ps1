$BootLog = "$HOME\pcloud_task_boot.log"
"Started at $(Get-Date)" | Add-Content $BootLog
"User: $env:USERNAME" | Add-Content $BootLog
"PWD: $(Get-Location)" | Add-Content $BootLog

$Jobs = @(
    @{
        Source = "E:\kawasaki\kawasaki"
        Dest   = 'pcloud:kawasaki'
    },
    @{
        Source = "E:\kawasaki\Studio One"
        Dest   = 'pcloud:kawasaki\Studio One'
    }
)

$LogDir = "$HOME\pcloud_upload_logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

while ($true) {
    $AllSucceeded = $true

    foreach ($Job in $Jobs) {
        $Source = $Job.Source
        $Dest   = $Job.Dest

        if (-not (Test-Path $Source)) {
            Write-Host "Source not found: $Source"
            $AllSucceeded = $false
            continue
        }

        $SafeName = ($Source -replace '[:\\\/]', '_')
        $Log = Join-Path $LogDir "$SafeName.log"

        Write-Host "Uploading:"
        Write-Host "  From: $Source"
        Write-Host "  To:   $Dest"

        rclone copy $Source $Dest `
            --progress `
            --transfers 4 `
            --checkers 8 `
            --retries 10 `
            --low-level-retries 20 `
            --log-file $Log `
            --log-level INFO

        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed: $Source"
            $AllSucceeded = $false
        }
    }

    if ($AllSucceeded) {
        Write-Host "All uploads completed successfully."
        break
    }

    Write-Host "Some uploads failed. Retrying all incomplete jobs in 60 seconds..."
    Start-Sleep -Seconds 60
}