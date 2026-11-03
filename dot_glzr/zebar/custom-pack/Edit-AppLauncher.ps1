Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'apps.json'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Zebar App Launcher Editor'
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(1200, 620)
$form.MinimumSize = New-Object System.Drawing.Size(1050, 560)
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
$grid.Size = New-Object System.Drawing.Size(870, 410)
$grid.Anchor = 'Top,Bottom,Left,Right'
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.RowHeadersVisible = $false
$grid.AutoSizeColumnsMode = 'Fill'
$grid.SelectionMode = 'FullRowSelect'
$grid.MultiSelect = $true
$grid.AllowDrop = $true
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
[void]$grid.Columns.Add('Group', 'まとめフォルダー')
$grid.Columns['Label'].FillWeight = 18
$grid.Columns['Program'].FillWeight = 48
$grid.Columns['Args'].FillWeight = 18
$grid.Columns['Icon'].FillWeight = 22
$grid.Columns['Group'].FillWeight = 20
$form.Controls.Add($grid)

$folderLabel = New-Object System.Windows.Forms.Label
$folderLabel.Text = 'ドロップ先フォルダー'
$folderLabel.Location = New-Object System.Drawing.Point(910, 80)
$folderLabel.Size = New-Object System.Drawing.Size(250, 24)
$folderLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($folderLabel)

$folderList = New-Object System.Windows.Forms.ListBox
$folderList.Location = New-Object System.Drawing.Point(910, 108)
$folderList.Size = New-Object System.Drawing.Size(250, 250)
$folderList.Anchor = 'Top,Right'
$folderList.AllowDrop = $true
$folderList.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 22)
$folderList.ForeColor = [System.Drawing.Color]::White
$folderList.BorderStyle = 'FixedSingle'
$form.Controls.Add($folderList)

$dragHint = New-Object System.Windows.Forms.Label
$dragHint.Text = "使い方:`n・行を上下へドラッグ → 並べ替え`n・行を右へドロップ → フォルダーへ追加`n・ルートへドロップ → フォルダーから外す`n・Ctrlで複数行をまとめて移動"
$dragHint.Location = New-Object System.Drawing.Point(910, 370)
$dragHint.Size = New-Object System.Drawing.Size(250, 110)
$dragHint.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($dragHint)

function New-Button([string]$text, [int]$x, [int]$width = 92) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x, 510)
    $button.Size = New-Object System.Drawing.Size($width, 34)
    $button.Anchor = 'Bottom,Left'
    $button.FlatStyle = 'Flat'
    $button.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 54)
    $button.ForeColor = [System.Drawing.Color]::White
    return $button
}

$addButton = New-Button 'アプリ追加' 20 92
$folderButton = New-Button 'フォルダー登録' 118 112
$removeButton = New-Button '削除' 236 72
$browseButton = New-Button 'EXE参照...' 314 92
$groupButton = New-Button 'まとめフォルダー' 412 128
$upButton = New-Button '↑ 上へ' 546 82
$downButton = New-Button '↓ 下へ' 634 82
$saveButton = New-Button '保存して反映' 1010 150
$saveButton.Anchor = 'Bottom,Right'
$saveButton.BackColor = [System.Drawing.Color]::FromArgb(65, 105, 155)

foreach ($button in $addButton, $folderButton, $removeButton, $browseButton, $groupButton, $upButton, $downButton, $saveButton) {
    $form.Controls.Add($button)
}

if (Test-Path -LiteralPath $configPath) {
    foreach ($app in (Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json)) {
        [void]$grid.Rows.Add($app.label, $app.program, $app.args, $app.icon, $app.group)
    }
}

function Refresh-FolderList {
    $selected = [string]$folderList.SelectedItem
    $folderList.Items.Clear()
    [void]$folderList.Items.Add('ルート')
    $groups = @(
        $grid.Rows |
            ForEach-Object { [string]$_.Cells['Group'].Value } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )
    foreach ($group in $groups) { [void]$folderList.Items.Add($group) }
    $index = $folderList.Items.IndexOf($selected)
    $folderList.SelectedIndex = if ($index -ge 0) { $index } else { 0 }
}

function Get-DraggedRowIndices($data) {
    if (-not $data.GetDataPresent('ZebarLauncherRows')) { return @() }
    return @(([string]$data.GetData('ZebarLauncherRows')).Split(',') | ForEach-Object { [int]$_ })
}

function Get-RowValues([int]$index) {
    return @($grid.Rows[$index].Cells | ForEach-Object { $_.Value })
}

$script:dragStart = [Drawing.Point]::Empty
$grid.Add_MouseDown({
    param($sender, $eventArgs)
    $script:dragStart = $eventArgs.Location
    $hit = $grid.HitTest($eventArgs.X, $eventArgs.Y)
    if ($hit.RowIndex -ge 0 -and -not $grid.Rows[$hit.RowIndex].Selected) {
        if (-not ([Windows.Forms.Control]::ModifierKeys -band [Windows.Forms.Keys]::Control)) {
            $grid.ClearSelection()
        }
        $grid.Rows[$hit.RowIndex].Selected = $true
    }
})

$grid.Add_MouseMove({
    param($sender, $eventArgs)
    if (-not ($eventArgs.Button -band [Windows.Forms.MouseButtons]::Left)) { return }
    if ([Math]::Abs($eventArgs.X - $script:dragStart.X) -lt 5 -and [Math]::Abs($eventArgs.Y - $script:dragStart.Y) -lt 5) { return }
    $indices = @($grid.SelectedRows | ForEach-Object Index | Sort-Object)
    if ($indices.Count -eq 0) { return }
    $data = New-Object Windows.Forms.DataObject
    $data.SetData('ZebarLauncherRows', ($indices -join ','))
    [void]$grid.DoDragDrop($data, [Windows.Forms.DragDropEffects]::Move)
})

$grid.Add_DragOver({
    param($sender, $eventArgs)
    $eventArgs.Effect = if ($eventArgs.Data.GetDataPresent('ZebarLauncherRows')) { 'Move' } else { 'None' }
})

$grid.Add_DragDrop({
    param($sender, $eventArgs)
    $indices = @(Get-DraggedRowIndices $eventArgs.Data)
    if ($indices.Count -eq 0) { return }
    $clientPoint = $grid.PointToClient((New-Object Drawing.Point($eventArgs.X, $eventArgs.Y)))
    $hit = $grid.HitTest($clientPoint.X, $clientPoint.Y)
    $target = if ($hit.RowIndex -ge 0) { $hit.RowIndex } else { $grid.Rows.Count }
    $movingRows = @($indices | ForEach-Object { ,(Get-RowValues $_) })
    $removedBeforeTarget = @($indices | Where-Object { $_ -lt $target }).Count
    foreach ($index in @($indices | Sort-Object -Descending)) { $grid.Rows.RemoveAt($index) }
    $target -= $removedBeforeTarget
    foreach ($values in $movingRows) {
        $grid.Rows.Insert($target, $values)
        $target++
    }
    $grid.ClearSelection()
    for ($i = $target - $movingRows.Count; $i -lt $target; $i++) { $grid.Rows[$i].Selected = $true }
})

$folderList.Add_DragEnter({
    param($sender, $eventArgs)
    $eventArgs.Effect = if ($eventArgs.Data.GetDataPresent('ZebarLauncherRows')) { 'Move' } else { 'None' }
})

$folderList.Add_DragOver({
    param($sender, $eventArgs)
    if (-not $eventArgs.Data.GetDataPresent('ZebarLauncherRows')) { $eventArgs.Effect = 'None'; return }
    $point = $folderList.PointToClient((New-Object Drawing.Point($eventArgs.X, $eventArgs.Y)))
    $index = $folderList.IndexFromPoint($point)
    if ($index -ge 0) { $folderList.SelectedIndex = $index }
    $eventArgs.Effect = 'Move'
})

$folderList.Add_DragDrop({
    param($sender, $eventArgs)
    $indices = @(Get-DraggedRowIndices $eventArgs.Data)
    if ($indices.Count -eq 0 -or $folderList.SelectedIndex -lt 0) { return }
    $folderName = [string]$folderList.SelectedItem
    if ($folderName -eq 'ルート') { $folderName = '' }
    foreach ($index in $indices) { $grid.Rows[$index].Cells['Group'].Value = $folderName }
    Refresh-FolderList
})

Refresh-FolderList

$addButton.Add_Click({
    $index = $grid.Rows.Add('新しいアプリ', '', '', 'nf-md-application', '')
    $grid.ClearSelection()
    $grid.Rows[$index].Selected = $true
    $grid.CurrentCell = $grid.Rows[$index].Cells['Label']
    $grid.BeginEdit($true)
    Refresh-FolderList
})

$folderButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'ランチャーから開くフォルダーを選択してください'
    $dialog.ShowNewFolderButton = $true
    if ($dialog.ShowDialog() -eq 'OK') {
        $path = $dialog.SelectedPath
        $label = Split-Path -Leaf $path
        if ([string]::IsNullOrWhiteSpace($label)) { $label = $path }
        $quotedPath = if ($path -match '\s') { '"' + $path + '"' } else { $path }
        $index = $grid.Rows.Add($label, 'C:\Windows\explorer.exe', $quotedPath, 'nf-fa-folder_open', '')
        $grid.ClearSelection()
        $grid.Rows[$index].Selected = $true
        Refresh-FolderList
    }
})

$removeButton.Add_Click({
    if ($grid.SelectedRows.Count -gt 0) {
        @($grid.SelectedRows | Sort-Object Index -Descending) | ForEach-Object {
            $grid.Rows.RemoveAt($_.Index)
        }
        Refresh-FolderList
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

$groupButton.Add_Click({
    if ($grid.SelectedRows.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('まとめたい項目を選択してください。Ctrlキーで複数選択できます。', '選択なし', 'OK', 'Information') | Out-Null
        return
    }
    $current = [string]$grid.SelectedRows[0].Cells['Group'].Value
    $name = [Microsoft.VisualBasic.Interaction]::InputBox(
        'まとめフォルダー名を入力してください。空欄でフォルダーから外します。',
        'まとめフォルダー',
        $current
    )
    foreach ($row in $grid.SelectedRows) {
        $row.Cells['Group'].Value = $name.Trim()
    }
    Refresh-FolderList
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
                label = $label
                program = $program
                args = [string]$row.Cells['Args'].Value
                icon = if ([string]::IsNullOrWhiteSpace([string]$row.Cells['Icon'].Value)) { 'nf-md-application' } else { [string]$row.Cells['Icon'].Value }
                group = [string]$row.Cells['Group'].Value
            }
        }
        $json = ConvertTo-Json -InputObject @($apps) -Depth 4
        [IO.File]::WriteAllText($configPath, $json, (New-Object Text.UTF8Encoding($false)))
        Get-Process zebar -ErrorAction SilentlyContinue | Stop-Process -Force
        Start-Process -FilePath 'zebar' -ArgumentList 'startup' -WindowStyle Hidden
        [System.Windows.Forms.MessageBox]::Show('保存してZebarへ反映しました。', '完了', 'OK', 'Information') | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, '保存エラー', 'OK', 'Error') | Out-Null
    }
})

[void]$form.ShowDialog()
