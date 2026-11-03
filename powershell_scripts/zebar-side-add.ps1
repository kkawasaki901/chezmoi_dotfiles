Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'apps.json'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Zebar App Launcher Editor'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(900, 520)
$form.MinimumSize = New-Object System.Drawing.Size(760, 420)
$form.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 28)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = 'アプリランチャーの編集'
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(18, 15)
$title.Font = New-Object System.Drawing.Font('Segoe UI', 15, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($title)

$hint = New-Object System.Windows.Forms.Label
$hint.Text = '名前・実行ファイル・引数・Nerd Fontアイコンクラスを編集できます。上から順に表示されます。'
$hint.AutoSize = $true
$hint.Location = New-Object System.Drawing.Point(20, 48)
$hint.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($hint)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(20, 80)
$grid.Size = New-Object System.Drawing.Size(840, 330)
$grid.Anchor = 'Top,Bottom,Left,Right'
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.RowHeadersVisible = $false
$grid.AutoSizeColumnsMode = 'Fill'
$grid.SelectionMode = 'FullRowSelect'
$grid.MultiSelect = $false
$grid.BackgroundColor = [System.Drawing.Color]::FromArgb(8, 8, 10)
$grid.GridColor = [System.Drawing.Color]::FromArgb(60, 60, 68)
$grid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 22)
$grid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(70, 95, 135)
$grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
$grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 48)
$grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.EnableHeadersVisualStyles = $false

[void]$grid.Columns.Add('Label', '表示名')
[void]$grid.Columns.Add('Program', '実行ファイル')
[void]$grid.Columns.Add('Args', '引数')
[void]$grid.Columns.Add('Icon', 'アイコン')
$grid.Columns['Label'].FillWeight = 18
$grid.Columns['Program'].FillWeight = 48
$grid.Columns['Args'].FillWeight = 18
$grid.Columns['Icon'].FillWeight = 22
$form.Controls.Add($grid)

function New-Button([string]$text, [int]$x, [int]$width = 92) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x, 426)
    $button.Size = New-Object System.Drawing.Size($width, 34)
    $button.Anchor = 'Bottom,Left'
    $button.FlatStyle = 'Flat'
    $button.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 54)
    $button.ForeColor = [System.Drawing.Color]::White
    return $button
}

$addButton = New-Button '追加' 20 76
$removeButton = New-Button '削除' 102 76
$browseButton = New-Button '参照...' 184 82
$upButton = New-Button '↑ 上へ' 272 82
$downButton = New-Button '↓ 下へ' 360 82
$saveButton = New-Button '保存して反映' 700 160
$saveButton.Anchor = 'Bottom,Right'
$saveButton.BackColor = [System.Drawing.Color]::FromArgb(65, 105, 155)

foreach ($button in $addButton, $removeButton, $browseButton, $upButton, $downButton, $saveButton) {
    $form.Controls.Add($button)
}

if (Test-Path -LiteralPath $configPath) {
    foreach ($app in (Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json)) {
        [void]$grid.Rows.Add($app.label, $app.program, $app.args, $app.icon)
    }
}

$addButton.Add_Click({
        $index = $grid.Rows.Add('新しいアプリ', '', '', 'nf-md-application')
        $grid.ClearSelection()
        $grid.Rows[$index].Selected = $true
        $grid.CurrentCell = $grid.Rows[$index].Cells['Label']
        $grid.BeginEdit($true)
    })

$removeButton.Add_Click({
        if ($grid.SelectedRows.Count -gt 0) {
            $grid.Rows.RemoveAt($grid.SelectedRows[0].Index)
        }
    })

$browseButton.Add_Click({
        if ($grid.SelectedRows.Count -eq 0) { return }
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = '実行ファイル (*.exe)|*.exe|すべてのファイル (*.*)|*.*'
        if ($dialog.ShowDialog() -eq 'OK') {
            $grid.SelectedRows[0].Cells['Program'].Value = $dialog.FileName
            if ([string]::IsNullOrWhiteSpace([string]$grid.SelectedRows[0].Cells['Label'].Value)) {
                $grid.SelectedRows[0].Cells['Label'].Value = [IO.Path]::GetFileNameWithoutExtension($dialog.FileName)
            }
        }
    })

function Move-SelectedRow([int]$offset) {
    if ($grid.SelectedRows.Count -eq 0) { return }
    $source = $grid.SelectedRows[0].Index
    $target = $source + $offset
    if ($target -lt 0 -or $target -ge $grid.Rows.Count) { return }
    $values = @($grid.Rows[$source].Cells | ForEach-Object { $_.Value })
    $grid.Rows.RemoveAt($source)
    $grid.Rows.Insert($target, $values)
    $grid.ClearSelection()
    $grid.Rows[$target].Selected = $true
}

$upButton.Add_Click({ Move-SelectedRow -offset -1 })
$downButton.Add_Click({ Move-SelectedRow -offset 1 })

$saveButton.Add_Click({
        try {
            $apps = @()
            foreach ($row in $grid.Rows) {
                $label = [string]$row.Cells['Label'].Value
                $program = [string]$row.Cells['Program'].Value
                if ([string]::IsNullOrWhiteSpace($label) -or [string]::IsNullOrWhiteSpace($program)) {
                    throw '表示名と実行ファイルは必須です。'
                }
                $apps += [ordered]@{
                    label   = $label
                    program = $program
                    args    = [string]$row.Cells['Args'].Value
                    icon    = if ([string]::IsNullOrWhiteSpace([string]$row.Cells['Icon'].Value)) { 'nf-md-application' } else { [string]$row.Cells['Icon'].Value }
                }
            }
            $json = ConvertTo-Json -InputObject @($apps) -Depth 4
            [IO.File]::WriteAllText($configPath, $json, (New-Object Text.UTF8Encoding($false)))
            Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force
            Start-Process -FilePath 'zebar' -ArgumentList 'startup' -WindowStyle Hidden
            [System.Windows.Forms.MessageBox]::Show('保存してZebarへ反映しました。', '完了', 'OK', 'Information') | Out-Null
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '保存エラー', 'OK', 'Error') | Out-Null
        }
    })

[void]$form.ShowDialog()
