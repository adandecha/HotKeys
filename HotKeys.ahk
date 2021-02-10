Full_Command_Line := DllCall("GetCommandLine", "str")
If Not (A_IsAdmin or RegExMatch(Full_Command_Line, " /restart(?!\S)"))
{
    try
    {
        If A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
}

#UseHook, On
#InstallKeybdHook
#SingleInstance, Force
Coordmode, ToolTip, Screen

M_On_Load := "HotKeys Loaded"
M_Enabled := "Hotkeys Enabled"
M_Disabled := "Hotkeys Disabled"
M_Caps_On := "Caps On"
M_Caps_Off := "Caps Off"

C_On_Load := 1
C_Caps_Toggle := 2
C_HK_Toggle := 3
C_Key_Press := 4
C_M_Arbitrary := 5

F_H_M_On_Load := Func("HideTip").Bind(C_On_Load)
F_H_M_Caps_Toggle := Func("HideTip").Bind(C_Caps_Toggle)
F_H_M_HK_Toggle := Func("HideTip").Bind(C_HK_Toggle)
F_H_M_Key_Press := Func("HideTip").Bind(C_Key_Press)
F_H_M_Arbitrary := Func("HideTip").Bind(C_M_Arbitrary)

ShowKeysOn := False

LogKeyPresses := False

AltTab := True

CaseState := 0
CaseText := ""

KeepExistingCapsLockStateButToPermState()

ShowTip(M_On_Load, C_On_Load, F_H_M_On_Load, True)

Suspend, On

Return

ShowTipArbitrary(ByRef Msg) {
    Global C_M_Arbitrary, F_H_M_Arbitrary
    ShowTip(Msg, C_M_Arbitrary, F_H_M_Arbitrary, True)
    Return
}

HideTip(ByRef Id) {
    ToolTip, , , , % Id
    Return
}

ShowTip(ByRef Text, ByRef ConstId, ByRef HiderFunc, ByRef Temp) {
    ToolTip, % Text, 0, 0, % ConstId

    If (Temp)
        SetTimer, % HiderFunc, -1000
    Else
        SetTimer, % HiderFunc, Off
    Return
}

KeepExistingCapsLockStateButToNormalState() {
    GetKeyState, kst, CapsLock, T
    SetCapsLockState, % ((kst = "U") ? "Off" : "On")
    Return
}

ToggleExistingCapsLockStateButToNormalState() {
    GetKeyState, kst, CapsLock, T
    SetCapsLockState, % ((kst = "D") ? "Off" : "On")
    Return
}

KeepExistingCapsLockStateButToPermState() {
    GetKeyState, kst, CapsLock, T
    If (kst = "U")
        MakeExistingCapsLockStatePermOff()
    else
        MakeExistingCapsLockStatePermOn()
    Return
}

ToggleExistingCapsLockStateToPermState() {
    GetKeyState, kst, CapsLock, T
    If (kst = "U")
        MakeExistingCapsLockStatePermOn()
    else
        MakeExistingCapsLockStatePermOff()
    Return
}

MakeExistingCapsLockStatePermOff() {
    Global F_H_M_Caps_Toggle
    SetCapsLockState, AlwaysOff
    F_H_M_Caps_Toggle.Call()
    Return
}

MakeExistingCapsLockStatePermOn() {
    Global M_Caps_On, C_Caps_Toggle, F_H_M_Caps_Toggle
    SetCapsLockState, AlwaysOn
    ShowTip(M_Caps_On, C_Caps_Toggle, F_H_M_Caps_Toggle, False)
    Return
}

OverlayCapsLockStatusMessage() {
    Global M_Caps_On ,C_Caps_Toggle, F_H_M_Caps_Toggle
    GetKeyState, kst, CapsLock, T
    If (kst = "D")
        ShowTip(M_Caps_On, C_Caps_Toggle, F_H_M_Caps_Toggle, False)
    Else
        F_H_M_Caps_Toggle.Call()
    Return
}

ShowKey(K) {
    Global ShowKeysOn, C_Key_Press, F_H_M_Key_Press, LogKeyPresses
    Static KeyPresses := ""
    M_Temp := True
    If (LogKeyPresses) {
        KeyPresses := % KeyPresses " " K
        K = % KeyPresses
        M_Temp := False
    }
    If (ShowKeysOn)
        ShowTip(K, C_Key_Press, F_H_M_Key_Press, M_Temp)
    Return
}

CapsLock & F1::
    Suspend, Permit
*F1::
    ShowKeysOn := !ShowKeysOn
    ShowKey("Show Help Messages.")
    Return

CapsLock & h::
    Suspend, Permit
*h::
    SendInput {Blind}{Left}
    ShowKey("Left")
    Return
CapsLock & j::
    Suspend, Permit
*j::
    SendInput {Blind}{Down}
    ShowKey("Down")
    Return
CapsLock & k::
    Suspend, Permit
*k::
    SendInput {Blind}{Up}
    ShowKey("Up")
    Return
CapsLock & l::
    Suspend, Permit
*l::
    SendInput {Blind}{Right}
    ShowKey("Right")
    Return

CapsLock & w::
    Suspend, Permit
*w::
    SendInput {Blind}{PgUp}
    ShowKey("Page Up")
    Return
CapsLock & a::
    Suspend, Permit
*a::
    SendInput {Blind}{Home}
    ShowKey("Home")
    Return
CapsLock & s::
    Suspend, Permit
*s::
    SendInput {Blind}{PgDn}
    ShowKey("Page Down")
    Return
CapsLock & d::
    Suspend, Permit
*d::
    SendInput {Blind}{End}
    ShowKey("End")
    Return

CapsLock & i::
    Suspend, Permit
*i::
    SendInput {Blind}{BackSpace}
    ShowKey("BackSpace")
    Return
CapsLock & o::
    Suspend, Permit
*o::
    SendInput {Blind}{Delete}
    ShowKey("Delete")
    Return

CapsLock & m::
    Suspend, Permit
*m::
    SendInput {AppsKey}
    ShowKey("Context Menu")
    Return
CapsLock & p::
    Suspend, Permit
*p::
    SendInput {Blind}{Click}
    ShowKey("Left Click")
    Return

CapsLock & x::
    Suspend, Permit
*x::
    SendInput ^x
    ShowKey("Cut")
    Return
CapsLock & c::
    Suspend, Permit
*c::
    SendInput ^c
    ShowKey("Copy")
    Return

CapsLock & v::
    Suspend, Permit
*v::
    SendInput +{Insert}
    ShowKey("Paste")
    Return
CapsLock & t::
    Suspend, Permit
*t::
    SendInput {text}%ClipBoard%
    ShowKey("Type in clipboard text ..")
    Return

CapsLock & u::
    Suspend, Permit
*u::
    SendInput ^z
    ShowKey("UnDo")
    Return
CapsLock & r::
    Suspend, Permit
*r::
    SendInput ^y
    ShowKey("ReDo")
    Return

CapsLock & f::
    Suspend, Permit
*f::
    SendInput ^f
    ShowKey("Find")
    Return

CapsLock & q::
    Suspend, Permit
*q::
    SendInput {Volume_Down}
    ShowKey("Volume Down")
    Return
CapsLock & e::
    Suspend, Permit
*e::
    SendInput {Volume_Up}
    ShowKey("Volume Up")
    Return

CapsLock & g::
    Suspend, Permit
*g::
    SendInput {Volume_Mute}
    ShowKey("Volume Mute")
    Return
CapsLock & z::
    Suspend, Permit
*z::
    SendInput {Media_Play_Pause}
    ShowKey("Media Play/Pause")
    Return

CapsLock & b::
    Suspend, Permit
*b::
    SendInput {Media_Previous}
    ShowKey("Media Previous")
    Return
CapsLock & n::
    Suspend, Permit
*n::
    SendInput {Media_Next}
    ShowKey("Media Next")
    Return

CapsLock & F5::
    Suspend, Permit
*F5::
    Reload
    Return
CapsLock & F4::
    Suspend, Permit
*F4::
    ShowTipArbitrary("Exiting HotKeys App ..")
    Sleep, 1000
    ExitApp

*#c::
    Suspend, Permit
    Run "calc.exe"
    ShowKey("Calculator")
    Return

CapsLock & 1::
    Suspend, Permit
*1::
    SendInput {Blind}{F1}
    ShowKey("F1")
    Return
CapsLock & 2::
    Suspend, Permit
*2::
    SendInput {Blind}{F2}
    ShowKey("F2")
    Return
CapsLock & 3::
    Suspend, Permit
*3::
    SendInput {Blind}{F3}
    ShowKey("F3")
    Return
CapsLock & 4::
    Suspend, Permit
*4::
    SendInput {Blind}{F4}
    ShowKey("F4")
    Return
CapsLock & 5::
    Suspend, Permit
*5::
    SendInput {Blind}{F5}
    ShowKey("F5")
    Return
CapsLock & 6::
    Suspend, Permit
*6::
    SendInput {Blind}{F6}
    ShowKey("F6")
    Return
CapsLock & 7::
    Suspend, Permit
*7::
    SendInput {Blind}{F7}
    ShowKey("F7")
    Return
CapsLock & 8::
    Suspend, Permit
*8::
    SendInput {Blind}{F8}
    ShowKey("F8")
    Return
CapsLock & 9::
    Suspend, Permit
*9::
    SendInput {Blind}{F9}
    ShowKey("F9")
    Return
CapsLock & 0::
    Suspend, Permit
*0::
    SendInput {Blind}{F10}
    ShowKey("F10")
    Return
CapsLock & -::
    Suspend, Permit
*-::
    SendInput {Blind}{F11}
    ShowKey("F11")
    Return
CapsLock & =::
    Suspend, Permit
*=::
    SendInput {Blind}{F12}
    ShowKey("F12")
    Return

CapsLock & Space::
    Suspend, Permit
    SendInput {Blind}{Space}
    ShowKey("Space")
    Return

CapsLock & [::
    Suspend, Permit
[::
    SendInput #p
    Sleep 500
    SendInput {Home}{Enter}{Esc}
    ShowKey("Display On PC Screen Only")
    Return

CapsLock & ]::
    Suspend, Permit
]::
    SendInput #p
    Sleep 500
    SendInput {End}{Enter}{Esc}
    ShowKey("Display On Second Screen Only")
    Return

CapsLock & Esc::
    Suspend, Permit
Esc::
    SendInput {Ctrl Down}{Shift Down}{Esc Down}{Ctrl Up}{Shift Up}{Esc Up}
    ShowKey("Task Manager")
    Return

CapsLock & y::
    Suspend, Permit
*y::
    SendInput #{PrintScreen}
    F_SK := Func("ShowKey").Bind("Saved screenshot at " RegExReplace(UserProfile, "\\", "/") "/Pictures/Screenshots")
    SetTimer, % F_SK, -500
    Return

CapsLock::
    Suspend, Permit
    ToggleExistingCapsLockStateToPermState()
    Return

RCtrl::
    Suspend
    If (A_IsSuspended) {
        ShowTip(M_Disabled, C_HK_Toggle, F_H_M_HK_Toggle, True)
    } else {
        ShowTip(M_Enabled, C_HK_Toggle, F_H_M_HK_Toggle, False)
        OverlayCapsLockStatusMessage()
    }
    Return

CapsLock & Tab::
    Suspend, Permit
    Global AltTab
    AltTab := Not AltTab
    If (AltTab)
        ShowKey("ReEnabling Alt+Tab Window Switching.")
    Else
        ShowKey("Disabling Alt+Tab Window Switching.")
    Return

!Tab::
    Suspend, Permit
    Global AltTab
    If (AltTab)
        SendInput {Alt Down}{Tab}
    Else
        ShowKey("Alt+Tab Window Switching Is Disabled.")
    Return

CapsLock & .::
    Suspend, Permit
    Global CaseState, CaseText
    ClipBoard := ""
    SendInput ^{Insert}
    Sleep 200
    ClipText := ClipBoard
    If (0 < StrLen(ClipText)) {
        CaseText := ClipText
    } Else If (0 < StrLen(CaseText)) {
        PrevTextLen := StrLen(CaseText)
        SendInput {BackSpace %PrevTextLen%}
    } Else {
        Return
    }
    If (CaseState = "0") {
        StringUpper ClipText, CaseText, T
        CaseState := 1
        ShowKey("Capitalise 1st Letters.")
    } else If (CaseState = "1") {
        StringUpper ClipText, CaseText
        CaseState := 2
        ShowKey("Capitalise All Letters.")
    } else If (CaseState = "2") {
        StringLower ClipText, CaseText
        CaseState := 3
        ShowKey("Lowercase All Letters.")
    } else {
        ClipText := CaseText
        CaseState := 0
        ShowKey("Restore Original Text.")
    }
    ClipBoard := ClipText
    SendInput +{Insert}
    SetTimer, ResetCaseState, -7000
    Return

ResetCaseState:
    Global CaseState, CaseText
    CaseState := 0
    CaseText := ""
    Return

