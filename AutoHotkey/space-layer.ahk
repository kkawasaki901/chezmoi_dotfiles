#Requires AutoHotkey v2.0
#SingleInstance Force

Persistent

; Space tapped normally produces Space. Holding it for this many milliseconds
; activates the layer until Space is released.
global SpaceLayerDelayMs := 200
global SpaceLayerHeld := false
global SpaceLayerActive := false
global ShortcutGui := BuildShortcutGui()
global ShortcutGuiVisible := false

; Diagnostic entry point used to preview the popup without synthesizing a key.
if A_Args.Length && A_Args[1] = "--show-shortcuts"
    SetTimer(ShowShortcutGui, -100)

; Quake-style cheat sheet: same key toggles it on and off, like the other
; Quake windows in alacritty-quake.ahk.
^!+k::ToggleShortcutGui()

$*Space:: {
    global SpaceLayerHeld, SpaceLayerActive, SpaceLayerDelayMs

    ; Ignore keyboard auto-repeat while Space is already held.
    if SpaceLayerHeld
        return

    SpaceLayerHeld := true
    SpaceLayerActive := false
    SetTimer(ActivateSpaceLayer, -SpaceLayerDelayMs)
}

$*Space Up:: {
    global SpaceLayerHeld, SpaceLayerActive

    SetTimer(ActivateSpaceLayer, 0)
    wasLayerActive := SpaceLayerActive
    SpaceLayerHeld := false
    SpaceLayerActive := false

    ; A short press remains an ordinary Space key.
    if !wasLayerActive
        SendEvent("{Blind}{Space}")
}

ActivateSpaceLayer() {
    global SpaceLayerHeld, SpaceLayerActive
    if SpaceLayerHeld
        SpaceLayerActive := true
}

#HotIf SpaceLayerActive

; Windows Japanese IME dedicated virtual keys.
$*j::SendEvent("{vk16}") ; VK_IME_ON
$*f::SendEvent("{vk1A}") ; VK_IME_OFF

; Editing keys in the Space layer.
$*h::SendEvent("{Blind}{Backspace}")
$*g::SendEvent("{Blind}{Space}")
$*b::SendEvent("{Blind}{Enter}")
$*v::SendEvent("{Blind}{Escape}")

#HotIf

BuildShortcutGui() {
    shortcutWindow := Gui("+AlwaysOnTop +ToolWindow +Border", "AutoHotkey Shortcut List")
    shortcutWindow.BackColor := "0B1020"
    shortcutWindow.MarginX := 24
    shortcutWindow.MarginY := 18
    shortcutWindow.OnEvent("Close", HideShortcutGui)
    shortcutWindow.OnEvent("Escape", HideShortcutGui)

    shortcutWindow.SetFont("s17 w700 cF8FAFC", "Segoe UI")
    shortcutWindow.AddText("xm ym w750 BackgroundTrans", "AUTOHOTKEY  /  SHORTCUTS")
    shortcutWindow.SetFont("s9 w400 c7DD3FC", "Segoe UI")
    shortcutWindow.AddText("xm y+4 w750 BackgroundTrans", "現在の常駐設定     •     自動では閉じません")
    shortcutWindow.AddProgress("xm y+12 w750 h1 Background334155 c334155", 100)

    AddShortcutSection(shortcutWindow, "GLOBAL / QUAKE")
    AddShortcutRow(shortcutWindow, "Alt + ``", "WezTerm", "専用Quakeを表示 / 非表示")
    AddShortcutRow(shortcutWindow, "Ctrl + Alt + Shift + 9", "Obsidian", "表示 / 非表示")
    AddShortcutRow(shortcutWindow, "Ctrl + Alt + Shift + 6", "Firefox Quake", "専用窓・位置とサイズを記憶")

    AddShortcutSection(shortcutWindow, "KEY LAYERS")
    AddShortcutRow(shortcutWindow, "Space 長押し", "Space Layer", "J=IME ON  F=OFF  H=BS  G=Space  B=Enter  V=Esc")
    AddShortcutRow(shortcutWindow, "Ctrl + Alt + Shift + K", "このカンニングペーパー", "表示 / 非表示（Quake方式）。ターミナルからは kanpe")

    AddShortcutSection(shortcutWindow, "COMMANDS")
    AddShortcutRow(shortcutWindow, "hp", "hermes profile", "fzfでプロファイルを選んでhermesを開く")
    AddShortcutRow(shortcutWindow, "hcron", "hermes cron", "fzfでcronジョブ結果を選んでbatで見る")
    AddShortcutRow(shortcutWindow, "kanpe", "このカンペ", "この一覧をターミナルに標準出力")

    shortcutWindow.SetFont("s10 w600", "Segoe UI")
    closeButton := shortcutWindow.AddButton("xm y+16 w160 h34", "閉じる  (Esc)")
    closeButton.OnEvent("Click", HideShortcutGui)
    return shortcutWindow
}

AddShortcutSection(window, title) {
    window.SetFont("s9 w700 c7DD3FC", "Segoe UI")
    window.AddText("xm y+13 w750 BackgroundTrans", title)
}

AddShortcutRow(window, shortcut, title, description) {
    window.SetFont("s10 w700 c0B1020", "Segoe UI")
    window.AddText("xm y+5 w205 h24 +0x200 Background7DD3FC", "  " shortcut)
    window.SetFont("s10 w600 cF8FAFC", "Segoe UI")
    window.AddText("x+10 yp w165 h24 +0x200 BackgroundTrans", title)
    window.SetFont("s9 w400 c94A3B8", "Segoe UI")
    window.AddText("x+8 yp w350 h24 +0x200 BackgroundTrans", description)
}

ToggleShortcutGui() {
    global ShortcutGuiVisible
    if ShortcutGuiVisible
        HideShortcutGui()
    else
        ShowShortcutGui()
}

ShowShortcutGui() {
    global ShortcutGui, ShortcutGuiVisible
    ShortcutGui.Show("AutoSize Hide")
    ShortcutGui.GetPos(, , &width, &height)

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
    x := left + Round(((right - left) - width) / 2)
    y := top + Round(((bottom - top) - height) / 2)
    ShortcutGui.Show("x" x " y" y)
    ShortcutGuiVisible := true
}

HideShortcutGui(*) {
    global ShortcutGui, ShortcutGuiVisible
    ShortcutGui.Hide()
    ShortcutGuiVisible := false
}


