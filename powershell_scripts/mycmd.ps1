



$commandsPath = "$HOME\powershell_scripts\commands.json"

if (!(Test-Path $commandsPath)) {
    Write-Host "commands.json が見つかりません: $commandsPath"
    return
}

$commands = Get-Content $commandsPath -Raw | ConvertFrom-Json

$selected = $commands |
    ForEach-Object {
        "$($_.name)`t$($_.description)"
    } |
    fzf --delimiter "`t" `
        --with-nth 1 `
        --preview "echo {2}" `
        --preview-window "right:60%:wrap"

if ([string]::IsNullOrWhiteSpace($selected)) {
    return
}

$name = ($selected -split "`t")[0]

$cmd = $commands | Where-Object { $_.name -eq $name } | Select-Object -First 1

if ($null -eq $cmd) {
    Write-Host "コマンドが見つかりません: $name"
    return
}

$commandText = $cmd.command

if ($cmd.input -eq $true) {
    $prompt = if ($cmd.inputPrompt) { $cmd.inputPrompt } else { "input" }
    $value = Read-Host $prompt
    if ([string]::IsNullOrWhiteSpace($value)) {
        return
    }

    $commandText = $commandText.Replace("{input}", $value)
}


Write-Host "実行: $commandText"
Invoke-Expression $commandText
