param([string]$CacheFile = (Join-Path (Split-Path $PSScriptRoot) 'agy_usage_cache.json'), [string]$PreviewPath, [ValidateSet("agy", "opencode-go", "cursor", "claude")][string]$Provider = "agy")

# Cache-only viewer: opening this window must never start agy.exe or hit the Cursor API.
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase
$mutex = New-Object Threading.Mutex($false, "Local\YASB-Quota-Window-$Provider")
if ($Provider -eq 'opencode-go') {
    $CacheFile = Join-Path $env:LOCALAPPDATA 'yasb-opencode-go\usage.json'
} elseif ($Provider -eq 'cursor') {
    $CacheFile = Join-Path (Split-Path $PSScriptRoot) 'cursor_usage_cache.json'
} elseif ($Provider -eq 'claude') {
    $CacheFile = Join-Path (Split-Path $PSScriptRoot) 'claude_usage_cache.json'
}
$owned = $false
try {
    try { $owned = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $owned = $true }
    if (-not $owned -and -not $PreviewPath) { return }
    [xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AGY · Quota" Width="500" SizeToContent="Height" MaxHeight="850"
        WindowStyle="None" ResizeMode="NoResize" AllowsTransparency="True"
        Background="Transparent" Topmost="True" ShowInTaskbar="False"
        FontFamily="Segoe UI" Foreground="#E9EDF7">
  <Border Background="#151A25" BorderBrush="#354056" BorderThickness="1" CornerRadius="20" Padding="25">
    <StackPanel>
      <Grid Margin="0,0,0,18">
        <StackPanel>
          <TextBlock x:Name="Brand" Text="ANTIGRAVITY" FontSize="11" FontWeight="Bold" Foreground="#8DABFF" />
          <TextBlock Text="Quota remaining" FontSize="27" FontWeight="SemiBold" Margin="0,5,0,0" />
        </StackPanel>
        <Button x:Name="CloseButton" Content="×" HorizontalAlignment="Right" VerticalAlignment="Top"
                Width="30" Height="30" FontSize="21" Foreground="#AAB5CB" Background="#252D3E" BorderThickness="0" Cursor="Hand" />
      </Grid>
      <TextBlock x:Name="Status" FontSize="11" Foreground="#9DAAC1" Margin="0,0,0,18" TextWrapping="Wrap" />
      <ScrollViewer VerticalScrollBarVisibility="Auto" MaxHeight="590">
        <StackPanel x:Name="Cards" />
      </ScrollViewer>
      <Grid Margin="0,8,0,0">
        <TextBlock Text="CACHED SNAPSHOT · no extra requests" FontSize="10" Foreground="#72829C" />
        <TextBlock Text="ESC to close" FontSize="10" Foreground="#72829C" HorizontalAlignment="Right" />
      </Grid>
    </StackPanel>
  </Border>
</Window>
'@
    $window = [Windows.Markup.XamlReader]::Load((New-Object Xml.XmlNodeReader $xaml))
    if ($Provider -eq 'opencode-go') {
        $window.Title = 'OpenCode Go - Quota'
        $window.FindName('Brand').Text = 'OPENCODE GO'
        $window.FindName('Brand').Foreground = '#63D8C0'
    } elseif ($Provider -eq 'cursor') {
        $window.Title = 'Cursor - Quota'
        $window.FindName('Brand').Text = 'CURSOR'
        $window.FindName('Brand').Foreground = '#9B7EF7'
    } elseif ($Provider -eq 'claude') {
        $window.Title = 'Claude - Quota'
        $window.FindName('Brand').Text = 'CLAUDE'
        $window.FindName('Brand').Foreground = '#D97757'
    }
    $cards = $window.FindName('Cards')
    $status = $window.FindName('Status')
    function New-Label([string]$Text, [double]$Size, [string]$Color) {
        $label = New-Object Windows.Controls.TextBlock
        $label.Text = $Text
        $label.FontSize = $Size
        $label.Foreground = $Color
        return $label
    }
    try {
        $data = [IO.File]::ReadAllText($CacheFile, [Text.Encoding]::UTF8) | ConvertFrom-Json -ErrorAction Stop
        if ($Provider -eq 'opencode-go') {
            $groups = @()
            foreach ($entry in @(@('rolling', 'Five-hour limit'), @('weekly', 'Weekly limit'), @('monthly', 'Monthly limit'))) {
                $quota = $data.usage.($entry[0])
                if ($null -eq $quota.percent -or $quota.percent -isnot [ValueType]) { throw 'Invalid quota data' }
                $groups += [pscustomobject]@{
                    name = $entry[1]
                    buckets = @([pscustomobject]@{
                        name = 'Remaining'
                        window = 'quota'
                        remaining_fraction = [Math]::Max(0.0, [Math]::Min(1.0, (1.0 - [double]$quota.percent / 100.0)))
                        reset_time = $quota.resetsAt
                    })
                }
            }
            $data = [pscustomobject]@{ status='SUCCESS'; command=@{ data=@{ groups=$groups } } }
        } elseif ($Provider -eq 'cursor') {
            $pu = $data.planUsage
            if ($null -eq $pu) { throw 'Invalid quota data' }
            $resetIso = $null
            if ($data.billingCycleEnd) {
                $resetIso = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$data.billingCycleEnd).ToString('o')
            }
            $buckets = @()
            foreach ($entry in @(@('totalPercentUsed', 'Total'), @('autoPercentUsed', 'Auto'), @('apiPercentUsed', 'API'))) {
                $val = $pu.($entry[0])
                if ($null -eq $val) { continue }
                $remaining = [Math]::Max(0.0, [Math]::Min(1.0, 1.0 - ([double]$val / 100.0)))
                $buckets += [pscustomobject]@{
                    name = $entry[1]
                    window = 'quota'
                    remaining_fraction = $remaining
                    reset_time = $resetIso
                }
            }
            if ($buckets.Count -eq 0) { throw 'Invalid quota data' }
            $data = [pscustomobject]@{ status = 'SUCCESS'; command = @{ data = @{ groups = @([pscustomobject]@{ name = 'Cursor Usage'; buckets = $buckets }) } } }
        } elseif ($Provider -eq 'claude') {
            $buckets = @()
            foreach ($entry in @(@('five_hour', 'Five-hour limit'), @('seven_day', 'Weekly limit'))) {
                $window2 = $data.($entry[0])
                if ($null -eq $window2 -or $null -eq $window2.utilization) { continue }
                $remaining = [Math]::Max(0.0, [Math]::Min(1.0, 1.0 - ([double]$window2.utilization / 100.0)))
                $buckets += [pscustomobject]@{
                    name = $entry[1]
                    window = 'quota'
                    remaining_fraction = $remaining
                    reset_time = $window2.resets_at
                }
            }
            if ($buckets.Count -eq 0) { throw 'Invalid quota data' }
            $data = [pscustomobject]@{ status = 'SUCCESS'; command = @{ data = @{ groups = @([pscustomobject]@{ name = 'Claude Usage'; buckets = $buckets }) } } }
        }
        if ($data.status -ne 'SUCCESS' -or -not $data.command.data.groups) { throw 'No quota groups' }
        $updated = (Get-Item -LiteralPath $CacheFile).LastWriteTime
        $status.Text = 'Updated ' + $updated.ToString('MM/dd HH:mm:ss') + '   ·   Local time'
        $failureFile = Join-Path $env:LOCALAPPDATA 'yasb-agy-usage\last-error.txt'
        if ($Provider -eq 'opencode-go') { $failureFile = Join-Path $env:LOCALAPPDATA 'yasb-opencode-go\failed.txt' }
        elseif ($Provider -eq 'cursor') { $failureFile = Join-Path $env:LOCALAPPDATA 'yasb-cursor-usage\last-error.txt' }
        elseif ($Provider -eq 'claude') { $failureFile = Join-Path $env:LOCALAPPDATA 'yasb-claude-usage\last-error.txt' }
        if (((Get-Date) - $updated).TotalMinutes -ge 5 -or (Test-Path $failureFile)) {
            $status.Text += '   ·   Cached / refresh pending'
            $status.Foreground = '#F3C780'
        }
        $palette = @('#8BA7FF', '#63D8C0', '#BB9AFF')
        $i = 0
        foreach ($group in $data.command.data.groups) {
            $accent = $palette[$i % $palette.Count]
            $i++
            $card = New-Object Windows.Controls.Border
            $card.Background = '#1E2635'
            $card.CornerRadius = 12
            $card.Padding = 17
            $card.Margin = '0,0,0,11'
            $body = New-Object Windows.Controls.StackPanel
            $card.Child = $body
            $title = New-Label $group.name 15 $accent
            $title.FontWeight = 'SemiBold'
            $title.Margin = '0,0,0,4'
            $body.Children.Add($title) | Out-Null
            foreach ($bucket in $group.buckets) {
                $valid = $null -ne $bucket.remaining_fraction
                $pct = if ($valid) { [Math]::Max(0, [Math]::Min(100, [Math]::Round([double]$bucket.remaining_fraction * 100))) } else { 0 }
                $color = if (-not $valid) { '#72829C' } elseif ($pct -le 15) { '#FF8998' } elseif ($pct -le 35) { '#F3C780' } else { $accent }
                $row = New-Object Windows.Controls.Grid
                $row.Margin = '0,11,0,7'
                $name = switch ($bucket.window) { 'weekly' { 'Weekly limit' } '5h' { 'Five-hour limit' } default { $bucket.name } }
                $row.Children.Add((New-Label $name 12 '#BDC8DC')) | Out-Null
                $value = New-Label $(if ($valid) { "$pct%" } else { '--' }) 18 $color
                $value.FontWeight = 'SemiBold'
                $value.HorizontalAlignment = 'Right'
                $row.Children.Add($value) | Out-Null
                $body.Children.Add($row) | Out-Null
                $track = New-Object Windows.Controls.Border
                $track.Height = 9
                $track.Background = '#303B50'
                $track.CornerRadius = 4.5
                $grid = New-Object Windows.Controls.Grid
                $remaining = New-Object Windows.Controls.ColumnDefinition
                $remaining.Width = New-Object Windows.GridLength($pct, [Windows.GridUnitType]::Star)
                $used = New-Object Windows.Controls.ColumnDefinition
                $used.Width = New-Object Windows.GridLength((100 - $pct), [Windows.GridUnitType]::Star)
                $grid.ColumnDefinitions.Add($remaining)
                $grid.ColumnDefinitions.Add($used)
                $fill = New-Object Windows.Controls.Border
                $fill.Background = $color
                $fill.CornerRadius = 4.5
                $grid.Children.Add($fill) | Out-Null
                $track.Child = $grid
                $body.Children.Add($track) | Out-Null
                $resetText = 'Reset time unavailable'
                try {
                    $reset = [DateTimeOffset]::Parse($bucket.reset_time)
                    $diff = $reset - [DateTimeOffset]::Now
                    $eta = if ($diff.TotalMinutes -le 0) { 'awaiting refresh' } elseif ($diff.TotalDays -ge 1) { "$([int][Math]::Floor($diff.TotalDays))d $($diff.Hours)h" } else { "$([int][Math]::Floor($diff.TotalHours))h $($diff.Minutes)m" }
                    $resetText = 'Resets ' + $reset.ToLocalTime().ToString('MM/dd HH:mm') + "   ·   $eta"
                } catch {}
                $resetLabel = New-Label $resetText 11 '#8D9DB8'
                $resetLabel.Margin = '0,7,0,0'
                $body.Children.Add($resetLabel) | Out-Null
            }
            $cards.Children.Add($card) | Out-Null
        }
    } catch {
        $status.Text = 'Quota data is not available yet. The bar will refresh automatically.'
        $status.Foreground = '#F3C780'
    }
    $window.FindName('CloseButton').Add_Click({ $window.Close() })
    $window.Add_KeyDown({ if ($_.Key -eq 'Escape') { $window.Close() } })
    $window.Add_MouseLeftButtonDown({ if ($_.ChangedButton -eq 'Left') { $window.DragMove() } })
    $window.Add_ContentRendered({
        $area = [Windows.SystemParameters]::WorkArea
        $window.Left = $area.Right - $window.ActualWidth - 18
        $window.Top = $area.Top + 14
        $window.Activate() | Out-Null
    })
    if ($PreviewPath) {
        $content = $window.Content
        $content.Measure((New-Object Windows.Size(500, 850)))
        $content.Arrange((New-Object Windows.Rect(0, 0, 500, $content.DesiredSize.Height)))
        $content.UpdateLayout()
        $bitmap = New-Object Windows.Media.Imaging.RenderTargetBitmap(500, ([int][Math]::Ceiling($content.ActualHeight)), 96, 96, [Windows.Media.PixelFormats]::Pbgra32)
        $bitmap.Render($content)
        $encoder = New-Object Windows.Media.Imaging.PngBitmapEncoder
        $encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($bitmap))
        $stream = [IO.File]::Create($PreviewPath)
        try { $encoder.Save($stream) } finally { $stream.Dispose() }
    } else {
        $window.ShowDialog() | Out-Null
    }
} finally {
    if ($owned) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
