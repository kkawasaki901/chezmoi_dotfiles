$ErrorActionPreference = 'SilentlyContinue'
$glazewm = "$env:USERPROFILE\scoop\shims\glazewm.exe"

& $glazewm command toggle-fullscreen 2>$null | Out-Null
Start-Sleep -Milliseconds 250

$focused = (& $glazewm query focused 2>$null | ConvertFrom-Json).data.focused
$isFullscreen = $focused.state.type -eq 'fullscreen'

Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public static class ZebarZOrder {
    public delegate bool EnumWindowsProc(IntPtr hwnd, IntPtr param);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc callback, IntPtr param);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hwnd, StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr insertAfter, int x, int y, int cx, int cy, uint flags);
}
'@

$insertAfter = if ($isFullscreen) { [IntPtr](-2) } else { [IntPtr](-1) }
$flags = [uint32]0x0013 # NOMOVE | NOSIZE | NOACTIVATE
[ZebarZOrder]::EnumWindows({
    param($hwnd, $param)
    $title = New-Object Text.StringBuilder 256
    [void][ZebarZOrder]::GetWindowText($hwnd, $title, $title.Capacity)
    if ($title.ToString() -eq 'Zebar - custom-pack / app-launcher') {
        [void][ZebarZOrder]::SetWindowPos($hwnd, $insertAfter, 0, 0, 0, 0, $flags)
    }
    return $true
}, [IntPtr]::Zero) | Out-Null
