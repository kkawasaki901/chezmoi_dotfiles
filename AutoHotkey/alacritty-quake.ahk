#Requires AutoHotkey v2.0
#SingleInstance Force

; Quake-style toggles for WezTerm, Obsidian, and the dedicated Firefox Quake window.
; SC029 = backtick (grave) key, used for WezTerm with Alt.
; Trimmed 2026-10-30: removed Alacritty, Raindrop.io, the plain Firefox toggle,
; the Zenn/Qiita and WSJ/X window pairs, the four-monitor dashboard, Chrome Quake,
; Focus To-Do Quake, Emacs Quake, Quick Memo Quake, Rio Quake, and Contour Quake.
; Full prior version kept at alacritty-quake.ahk.bak-20261030-trim.
Persistent
DetectHiddenWindows true
SetTitleMatchMode 3

global ScaleRatio := 0.80
global WezTermWindow := "ahk_class WezTermQuake"
global WezTermExe := "C:\Program Files\WezTerm\wezterm-gui.exe"
global WezTermHwnd := 0
global ObsidianExe := "C:\Users\kawasaki\AppData\Local\Obsidian\Obsidian.exe"
global ObsidianHwnd := 0
global FirefoxExe := "C:\Program Files\Mozilla Firefox\firefox.exe"
global FirefoxQuakeHwnd := 0
global FirefoxQuakeStatePath := A_ScriptDir "\firefox-quake.ini"

!sc029::ToggleWezTermQuake()
^!+9::ToggleObsidian()
^!+6::ToggleFirefoxQuake()

ToggleWezTermQuake() {
    global WezTermWindow, WezTermExe, WezTermHwnd

    hwnd := WezTermHwnd && WinExist("ahk_id " WezTermHwnd) ? WezTermHwnd : WinExist(WezTermWindow)
    if !hwnd {
        command := '"' WezTermExe '" start --always-new-process --class WezTermQuake --workspace quake'
        try Run(command)
        catch as err {
            MsgBox("WezTermを起動できませんでした。`n`n" err.Message, "WezTerm Quake")
            return
        }

        if !WinWait(WezTermWindow, , 10) {
            MsgBox("WezTermのウィンドウが10秒以内に見つかりませんでした。", "WezTerm Quake")
            return
        }
        hwnd := WinExist(WezTermWindow)
        WezTermHwnd := hwnd
        ; WezTerm may apply its configured startup size just after creating the window.
        Sleep(1200)
        PrepareQuakeWindow(hwnd)
        return
    }

    WezTermHwnd := hwnd
    target := "ahk_id " hwnd
    if DllCall("IsWindowVisible", "Ptr", hwnd) && WinGetMinMax(target) != -1 {
        WinHide(target)
        return
    }

    WinShow(target)
    WinRestore(target)
    PositionOnCurrentMonitor(hwnd)
    WinSetAlwaysOnTop(1, target)
    WinActivate(target)
}

; Plain show/hide toggle on the monitor under the mouse cursor.
; Deliberately keeps the normal window frame (no WinSetStyle) — stripping the
; title bar previously made Obsidian (Electron) render solid black.
ToggleObsidian() {
    global ObsidianExe, ObsidianHwnd

    hwnd := ObsidianHwnd && WinExist("ahk_id " ObsidianHwnd) ? ObsidianHwnd : FindObsidianWindow()
    if !hwnd {
        try Run('"' ObsidianExe '"')
        catch as err {
            MsgBox("Obsidianを起動できませんでした。`n`n" err.Message, "Obsidian")
            return
        }

        deadline := A_TickCount + 15000
        while !hwnd && A_TickCount < deadline {
            hwnd := FindObsidianWindow()
            Sleep(100)
        }
        if !hwnd {
            MsgBox("Obsidianのウィンドウが15秒以内に見つかりませんでした。", "Obsidian")
            return
        }
        ObsidianHwnd := hwnd
        ; Obsidian(Electron)の初期描画・レイアウト確定を待つ
        Sleep(500)
        WinRestore("ahk_id " hwnd)
        PositionOnCurrentMonitor(hwnd)
        WinSetAlwaysOnTop(0, "ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)
        return
    }

    ObsidianHwnd := hwnd
    target := "ahk_id " hwnd
    if DllCall("IsWindowVisible", "Ptr", hwnd) && WinGetMinMax(target) != -1 {
        WinHide(target)
        return
    }

    WinShow(target)
    WinRestore(target)
    PositionOnCurrentMonitor(hwnd)
    WinActivate(target)
}

FindObsidianWindow() {
    ; Electron creates several hidden helper windows under Obsidian.exe.
    ; The real vault window has Chrome_WidgetWin_1 and a non-empty title.
    for hwnd in WinGetList("ahk_exe Obsidian.exe") {
        try {
            if WinGetClass("ahk_id " hwnd) = "Chrome_WidgetWin_1"
                && WinGetTitle("ahk_id " hwnd) != "" {
                return hwnd
            }
        }
    }
    return 0
}

; Firefox Quake that remembers the geometry the user last chose.  Geometry is
; persisted so it also survives an AutoHotkey reload or Windows sign-in.
ToggleFirefoxQuake() {
    global FirefoxQuakeHwnd

    hwnd := FirefoxQuakeHwnd && WinExist("ahk_id " FirefoxQuakeHwnd) ? FirefoxQuakeHwnd : FindTaggedFirefoxWindow("Codex_FirefoxQuake")
    if !hwnd {
        hwnd := LaunchNewFirefoxWindow("about:newtab")
        if !hwnd {
            return
        }
        TagFirefoxWindow(hwnd, "Codex_FirefoxQuake")
        FirefoxQuakeHwnd := hwnd
        Sleep(500)
        RestoreFirefoxQuakeGeometry(hwnd)
        WinSetAlwaysOnTop(1, "ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)
        return
    }

    FirefoxQuakeHwnd := hwnd
    target := "ahk_id " hwnd
    if DllCall("IsWindowVisible", "Ptr", hwnd) && WinGetMinMax(target) != -1 {
        SaveFirefoxQuakeGeometry(hwnd)
        WinHide(target)
        return
    }

    WinShow(target)
    RestoreFirefoxQuakeGeometry(hwnd)
    WinSetAlwaysOnTop(1, target)
    WinActivate(target)
}

SaveFirefoxQuakeGeometry(hwnd) {
    global FirefoxQuakeStatePath
    target := "ahk_id " hwnd
    state := WinGetMinMax(target)
    IniWrite(state, FirefoxQuakeStatePath, "Window", "State")
    if state = 0 {
        WinGetPos(&x, &y, &width, &height, target)
        IniWrite(x, FirefoxQuakeStatePath, "Window", "X")
        IniWrite(y, FirefoxQuakeStatePath, "Window", "Y")
        IniWrite(width, FirefoxQuakeStatePath, "Window", "Width")
        IniWrite(height, FirefoxQuakeStatePath, "Window", "Height")
    }
}

RestoreFirefoxQuakeGeometry(hwnd) {
    global FirefoxQuakeStatePath
    target := "ahk_id " hwnd
    WinRestore(target)

    if !FileExist(FirefoxQuakeStatePath) {
        PositionOnCurrentMonitor(hwnd)
        return
    }

    state := IniRead(FirefoxQuakeStatePath, "Window", "State", "0")
    x := IniRead(FirefoxQuakeStatePath, "Window", "X", "")
    y := IniRead(FirefoxQuakeStatePath, "Window", "Y", "")
    width := IniRead(FirefoxQuakeStatePath, "Window", "Width", "")
    height := IniRead(FirefoxQuakeStatePath, "Window", "Height", "")
    if x != "" && y != "" && width >= 200 && height >= 150
        WinMove(x, y, width, height, target)
    else
        PositionOnCurrentMonitor(hwnd)

    if state = 1
        WinMaximize(target)
}

LaunchNewFirefoxWindow(url) {
    global FirefoxExe
    existingWindows := Map()
    for hwnd in WinGetList("ahk_exe firefox.exe")
        existingWindows[hwnd] := true

    try Run('"' FirefoxExe '" -new-window "' url '"')
    catch as err {
        MsgBox("Firefoxウィンドウを起動できませんでした。`n`n" err.Message, "Firefox Quake")
        return 0
    }

    deadline := A_TickCount + 15000
    while A_TickCount < deadline {
        for hwnd in WinGetList("ahk_exe firefox.exe") {
            try {
                if !existingWindows.Has(hwnd)
                    && WinGetClass("ahk_id " hwnd) = "MozillaWindowClass" {
                    return hwnd
                }
            }
        }
        Sleep(100)
    }

    MsgBox("新しいFirefoxウィンドウが15秒以内に見つかりませんでした。", "Firefox Quake")
    return 0
}

TagFirefoxWindow(hwnd, tag) {
    return DllCall("SetPropW", "Ptr", hwnd, "Str", tag, "Ptr", 1, "Int")
}

FindTaggedFirefoxWindow(tag) {
    for hwnd in WinGetList("ahk_exe firefox.exe") {
        if DllCall("GetPropW", "Ptr", hwnd, "Str", tag, "Ptr")
            return hwnd
    }
    return 0
}

PrepareQuakeWindow(hwnd) {
    target := "ahk_id " hwnd
    WinRestore(target)
    ; Remove the title bar and resize border for a Quake-style drop-down panel.
    WinSetStyle("-0xC40000", target)
    PositionOnCurrentMonitor(hwnd)
    WinSetAlwaysOnTop(1, target)
    WinActivate(target)
}

PositionOnCurrentMonitor(hwnd) {
    global ScaleRatio

    MouseGetPos(&mouseX, &mouseY)
    monitor := MonitorGetPrimary()
    Loop MonitorGetCount() {
        MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
        if mouseX >= left && mouseX < right && mouseY >= top && mouseY < bottom {
            monitor := A_Index
            break
        }
    }

    MonitorGetWorkArea(monitor, &left, &top, &right, &bottom)
    workWidth := right - left
    workHeight := bottom - top
    width := Round(workWidth * ScaleRatio)
    height := Round(workHeight * ScaleRatio)
    x := left + Round((workWidth - width) / 2)
    y := top + Round((workHeight - height) / 2)
    WinMove(x, y, width, height, "ahk_id " hwnd)
}
