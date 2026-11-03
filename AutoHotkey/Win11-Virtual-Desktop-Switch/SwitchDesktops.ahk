#Requires AutoHotkey v2.0

; === Load VirtualDesktopAccessor.dll ===
dllPath := A_ScriptDir "\VirtualDesktopAccessor.dll"
hVDA := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
if !hVDA {
    MsgBox "❌ Failed to load VirtualDesktopAccessor.dll.`nMake sure it's in the same folder as this script."
    ExitApp
}

; === Resolve DLL functions ===
GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GoToDesktopNumber", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "CreateDesktop", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetCurrentDesktopNumber", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "RemoveDesktop", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetDesktopName", "Ptr")

; === Wrapper functions ===
GetDesktopCount() {
    global GetDesktopCountProc
    return DllCall(GetDesktopCountProc, "Int")
}

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num, "Int")
}

CreateDesktop() {
    global CreateDesktopProc
    return DllCall(CreateDesktopProc)
}

GetCurrentDesktopNumber() {
    global GetCurrentDesktopNumberProc
    return DllCall(GetCurrentDesktopNumberProc, "Int")
}

RemoveDesktop(current, fallback) {
    global RemoveDesktopProc
    DllCall(RemoveDesktopProc, "Int", current, "Int", fallback)
}

GetDesktopName(num) {
    global GetDesktopNameProc

    if !GetDesktopNameProc
        return ""

    nameBuffer := Buffer(1024, 0)
    result := DllCall(
        GetDesktopNameProc,
        "Int", num,
        "Ptr", nameBuffer.Ptr,
        "UPtr", nameBuffer.Size,
        "Int"
    )

    if (result = -1)
        return ""

    return StrGet(nameBuffer.Ptr, "UTF-8")
}

; === Main function: Switch only if the desktop already exists ===
SwitchDesktop(num) {
    count := GetDesktopCount()
    if (num < 0 || num >= count)
        return

    GoToDesktopNumber(num)
}

; === Desktop picker GUI ===
ShowDesktopPicker() {
    count := GetDesktopCount()
    if (count <= 0)
        return

    pickerGui := Gui("+AlwaysOnTop", "仮想デスクトップ")
    pickerGui.MarginX := 16
    pickerGui.MarginY := 16
    pickerGui.SetFont("s11", "Yu Gothic UI")
    pickerGui.OnEvent("Escape", (*) => pickerGui.Destroy())
    pickerGui.OnEvent("Close", (*) => pickerGui.Destroy())

    currentDesktop := GetCurrentDesktopNumber()

    Loop count {
        desktopNumber := A_Index - 1
        desktopName := GetDesktopName(desktopNumber)
        if (desktopName = "")
            desktopName := "デスクトップ " A_Index

        buttonOptions := "w280 h42"
        if (desktopNumber = currentDesktop)
            buttonOptions .= " Default"

        desktopButton := pickerGui.AddButton(buttonOptions, desktopName)
        desktopButton.OnEvent(
            "Click",
            SelectDesktopFromPicker.Bind(desktopNumber, pickerGui)
        )
    }

    pickerGui.Show("AutoSize Center")
}

SelectDesktopFromPicker(desktopNumber, pickerGui, *) {
    ; Switch first so the current desktop is not redrawn between Hide and switch.
    SwitchDesktop(desktopNumber)
    pickerGui.Destroy()
}

; === Close current desktop ===
CloseCurrentDesktop() {
    curr := GetCurrentDesktopNumber()
    count := GetDesktopCount()
    if (count <= 1) {
        MsgBox "⚠️ Cannot close the last desktop!"
        return
    }

    fallback := (curr > 0) ? (curr - 1) : (curr + 1)
    RemoveDesktop(curr, fallback)
    GoToDesktopNumber(fallback)
}

; === ALT + 1–9 hotkeys ===
!1::SwitchDesktop(0)
!2::SwitchDesktop(1)
!3::SwitchDesktop(2)
!4::SwitchDesktop(3)
!5::SwitchDesktop(4)
!6::SwitchDesktop(5)
!7::SwitchDesktop(6)
!8::SwitchDesktop(7)
!9::SwitchDesktop(8)

; === Alternative ALT hotkeys for desktops 4–9 ===
!q::SwitchDesktop(3)
!w::SwitchDesktop(4)
!e::SwitchDesktop(5)
!a::SwitchDesktop(6)
!s::SwitchDesktop(7)
!d::SwitchDesktop(8)

; === ALT + Z: Open desktop picker ===
!z::ShowDesktopPicker()
