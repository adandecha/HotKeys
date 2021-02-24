Version := 1.0
LatestVersionURL := "https://raw.githubusercontent.com/adandecha/HotKeys/map2/Values/Version"
HotKeysExeDLURL := "https://github.com/adandecha/HostedFilesPublic/raw/master/HotKeys.exe"

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
#MaxThreads 4
#MaxHotkeysPerInterval 10000000

Coordmode, ToolTip, Screen
SetFormat, Float, .2

ConfigDir := A_AppData "\HotKeys"
FP_Variables := ConfigDir "\Variables" 
FP_ClipTexts := ConfigDir "\ClipTexts"
FileCreateDir, % FP_Variables
FileCreateDir, % FP_ClipTexts

LastSize := ""
LastSizeTick := ""

; A way to temp change version manually to too high or too low
; So as to either avoid update or force DL update
Version := ConfigGet("Version", Version)

RmConfigOnExit := False

RegRead, ScreenshotsDir, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, {B7BEDE81-DF94-4682-A7D8-57A52620B86F}, % UserProfile "\Pictures\Screenshots"
ScreenshotsDir := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c <nul set /p=" ScreenshotsDir).StdOut.ReadAll()

M_On_Load := "HotKeys v" Version " Loaded"
M_HK_Enabled := "Hotkeys Enabled"
M_HK_Disabled := "Hotkeys Disabled"
M_Caps_On := "Caps On"
M_Caps_Off := "Caps Off"

C_On_Load := 1
C_Caps_Toggle := 2
C_HK_Toggle := 3
C_Key_Press := 4
C_M_Arbitrary := 5
C_M_ClipBoard := 6
C_M_LastToolTip := 7

HiderFuncs := {}

ShowLastNotif := True
ToolTipCoOrdX := ConfigGet("ToolTipCoOrdX", 0)
ToolTipCoOrdY := ConfigGet("ToolTipCoOrdY", 0)
LastToolTipText := ""
LastToolTipID := ""

F_S_M_HK_Enabled := Func("ShowTip").Bind(M_HK_Enabled, C_HK_Toggle, False)

NotifDisplayTime := 3000

ShowKeysOn := ConfigGet("ShowKeysOn", False)

LogKeyPresses := False

AltTab := ConfigGet("AltTab", True)

CaseChangeState := 0
CaseChangeText := ""

KeepExistingCapsLockStateButToPermState()

If (0 < A_Args.Count() && A_Args[1] == "-ShowMsgUpdated") {
    ShowTip("Cheers!`nNow Running The Latest HotKeys v" Version "!`n", C_On_Load, True)
} Else If (0 < A_Args.Count() && A_Args[1] == "-UpdateFailed") {
    ShowTip("Update Failed!", C_On_Load, True)
} Else {
    ShowTip(M_On_Load, C_On_Load, True)
}

ExpectedClipBoardUpdateTime := 200

ClipStack := []
LoadClipBoardHistoryOffOfDisk()
ClipStackCount := ClipStack.Count()
ClipStackCurr := ConfigGet("ClipStackCurr", ClipStackCount)
OnClipBoardChange("ClipBoardListener")
DisableClipBoardMsgs := ConfigGet("DisableClipBoardMsgs", True)
DisableClipBoardListener := False
SetTimer, ClipBoardPopulate, -1

FuncOfW := ConfigGet("FuncOfW", "DoUp")
SetWASDHJKL((FuncOfW == "DoUp"))

NextScrollWaitTime := 500

Suspend, On

Return

ConfigGet(ByRef Var, ByRef Val := "") {
    Global FP_Variables
    FP := FP_Variables "\" Var ".txt"
    If FileExist(FP) {
        FileRead, Val, % FP_Variables "\" Var ".txt"
    } Else {
        ConfigSet(Var, Val)
    }
    Return, % Val
}

ConfigSet(ByRef Var, ByRef Val) {
    Global FP_Variables
    F := FileOpen(FP_Variables "\" Var ".txt", "w")
    F.Write(Val)
    F.Close()
    Return, % Val
}

SwapFuncOfMovementKeys() {
    Global FuncOfW
    SetWASDHJKL((FuncOfW != "DoUp"))
}

SetWASDHJKL(FuncOfW_Is_To_DoUp) {
    Global FuncOfW, FuncOfA, FuncOfS, FuncOfD, FuncOfH, FuncOfJ, FuncOfK, FuncOfL
    If (FuncOfW_Is_To_DoUp) {
        FuncOfW := "DoUp"
        FuncOfA := "DoLeft"
        FuncOfS := "DoDown"
        FuncOfD := "DoRight"
        FuncOfH := "DoHome"
        FuncOfJ := "DoPageDown"
        FuncOfK := "DoPageUp"
        FuncOfL := "DoEnd"
    } Else {
        FuncOfW := "DoPageUp"
        FuncOfA := "DoHome"
        FuncOfS := "DoPageDown"
        FuncOfD := "DoEnd"
        FuncOfH := "DoLeft"
        FuncOfJ := "DoDown"
        FuncOfK := "DoUp"
        FuncOfL := "DoRight"
    }
}

ShowTipArbitrary(ByRef Msg, ByRef ShowTemporarily := True) {
    Global C_M_Arbitrary
    ShowTip(Msg, C_M_Arbitrary, ShowTemporarily)
    Return
}

HideTipArbitrary() {
    Global C_M_Arbitrary
    CallTipHider(C_M_Arbitrary)
}

ShowTipClipBoard(ByRef Msg, ByRef ShowTemporarily := True) {
    Global C_M_ClipBoard, DisableClipBoardMsgs
    If DisableClipBoardMsgs {
        HideTipClipBoard()
        Return
    }
    ShowTip(Msg, C_M_ClipBoard, ShowTemporarily)
    Return
}

HideTipClipBoard() {
    Global C_M_ClipBoard
    CallTipHider(C_M_ClipBoard)
}

CallTipHider(TipID) {
    Global HiderFuncs
    If !HiderFuncs.HasKey(TipID)
        HiderFuncs[TipID] := Func("HideTip").Bind(TipID)
    HF := HiderFuncs[TipID]
    %HF%()
}

HideTip(ByRef TipID) {
    ToolTip, , , , % TipId
    Return
}

; ConstID is IMP
; ShowTip will only hide prev notif of same ConstID class
; Essentially grouping together same class of notifs which should not be dispalyed together or be overwritten by newer msgs
ShowTip(ByRef Text, ByRef ConstID, ByRef ShowTemporarily) {
    Global HiderFuncs, NotifDisplayTime, LastToolTipText, LastToolTipID, ToolTipCoOrdX, ToolTipCoOrdY

    LastToolTipText := Text
    LastToolTipID := ConstID

    ; If don't setup like below, all "SetTimer, % HiderFunc, Delete" calls will be unique
    ; and thus all new tooltips will start disappearing before %NotifDisplayTime
    ; so what you want is that SetTimer find HiderFunc functions to be the same
    ; so that it can relate a settimer, hf, del call's hf with prev settimer, hf, -ndt call's hf
    If !HiderFuncs.HasKey(ConstID)
        HiderFuncs[ConstId] := Func("HideTip").Bind(ConstId)
    HiderFunc := HiderFuncs[ConstId]
    ; %HiderFunc%()

    ToolTip, % Text, % ToolTipCoOrdX, % ToolTipCoOrdY, % ConstID

    ; SetTimer, % HiderFunc, Delete

    If (ShowTemporarily)
        SetTimer, % HiderFunc, % -NotifDisplayTime
    Else
        SetTimer, % HiderFunc, Delete
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
    Global C_Caps_Toggle, HiderFuncs
    SetCapsLockState, AlwaysOff
    HF := HiderFuncs[C_Caps_Toggle]
    %HF%()
    Return
}

MakeExistingCapsLockStatePermOn() {
    Global M_Caps_On, C_Caps_Toggle
    SetCapsLockState, AlwaysOn
    ShowTip(M_Caps_On, C_Caps_Toggle, False)
    Return
}

OverlayCapsLockStatusMessage() {
    Global M_Caps_On ,C_Caps_Toggle
    GetKeyState, kst, CapsLock, T
    If (kst = "D")
        ShowTip(M_Caps_On, C_Caps_Toggle, False)
    Else {
        HF := HiderFuncs[C_Caps_Toggle]
        %HF%()
    }
    Return
}

ShowKey(K) {
    Global ShowKeysOn, C_Key_Press, LogKeyPresses
    Static KeyPresses := ""
    M_Temp := True
    If (LogKeyPresses) {
        KeyPresses := % KeyPresses " " K
        K = % KeyPresses
        M_Temp := False
    }
    If (ShowKeysOn)
        ShowTip(K, C_Key_Press, M_Temp)
    Else
        HideTip(C_Key_Press)
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
    %FuncOfH%()
    Return

DoLeft() {
    SendInput {Blind}{Left}
    ShowKey("Left")
    Return
}

CapsLock & j::
    Suspend, Permit
*j::
    %FuncOfJ%()
    Return

DoDown() {
    SendInput {Blind}{Down}
    ShowKey("Down")
    Return
}

CapsLock & k::
    Suspend, Permit
*k::
    %FuncOfK%()
    Return

DoUp() {
    SendInput {Blind}{Up}
    ShowKey("Up")
    Return
}

CapsLock & l::
    Suspend, Permit
*l::
    %FuncOfL%()
    Return

DoRight() {
    SendInput {Blind}{Right}
    ShowKey("Right")
    Return
}

CapsLock & a::
    Suspend, Permit
*a::
    %FuncOfA%()
    Return

DoHome() {
    SendInput {Blind}{Home}
    ShowKey("Home")
    Return
}

CapsLock & s::
    Suspend, Permit
*s::
    %FuncOfS%()
    Return

DoPageDown() {
    SendInput {Blind}{PgDn}
    ShowKey("Page Down")
    Return
}

CapsLock & w::
    Suspend, Permit
*w::
    %FuncOfW%()
    Return

DoPageUp() {
    SendInput {Blind}{PgUp}
    ShowKey("Page Up")
    Return
}

CapsLock & d::
    Suspend, Permit
*d::
    %FuncOfD%()
    Return

DoEnd() {
    SendInput {Blind}{End}
    ShowKey("End")
    Return
}

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

CapsLock & '::
    Suspend, Permit
*'::
    SendInput {AppsKey}
    ShowKey("Context Menu")
    Return
CapsLock & `;::
    Suspend, Permit
`;::
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
    ShowKey("Types ClipBoard Text.")
    Return

CapsLock & u::
    Suspend, Permit
*u::
    If GetKeyState("Alt") {
        ShowKey("Check For Update.")
        SetTimer, CheckForUpdates, -1
    } Else {
        SendInput ^z
        ShowKey("UnDo")
    }
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

CapsLock & ,::
    Suspend, Permit
*,::
    If !GetKeyState("Shift") {
        SendInput {Volume_Down}
        ShowKey("Volume Down")
    } Else {
        SendInput {Media_Prev}
        ShowKey("Media Previous")
    }
    Return

CapsLock & .::
    Suspend, Permit
*.::
    If !GetKeyState("Shift") {
        SendInput {Volume_Up}
        ShowKey("Volume Up")
    } Else {
        SendInput {Media_Next}
        ShowKey("Media Next")
    }
    Return

CapsLock & /::
    Suspend, Permit
*/::
    If !GetKeyState("Shift") {
        SendInput {Volume_Mute}
        ShowKey("Volume Mute")
    } Else {
        SendInput {Media_Play_Pause}
        ShowKey("Media Play/Pause")
    }
    Return

CapsLock & F5::
    Suspend, Permit
*F5::
    ExitSub()
    Reload
    Return
CapsLock & F4::
    Suspend, Permit
*F4::
    ExitSub()
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
    ShowKey("Display Only On PC Screen.")
    Return

CapsLock & ]::
    Suspend, Permit
]::
    SendInput #p
    Sleep 500
    SendInput {End}{Enter}{Esc}
    ShowKey("Display Only On Second Screen.")
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
    Global ScreenshotsDir
    RegRead, Idx, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer, ScreenshotIndex, "02"
    Idx--
    ScreenShotFilePath := ScreenshotsDir "\Screenshot (" Idx ").png"
    If GetKeyState("Alt") {
        ShowKey("Show ScreenShot In Explorer.")
        RunString := "explorer /select, " ScreenShotFilePath
        Run, % RunString
    } Else If GetKeyState("Ctrl") {
        ShowKey("Copy ScreenShot FilePath On The ClipBoard.")
        RegRead, Idx, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer, ScreenshotIndex, "02"
        Idx--
        ClipBoard := ScreenShotFilePath
    } Else {
        SendInput #{PrintScreen}
        F_SK := Func("ShowKey").Bind("Saved ScreenShot At " ScreenShotFilePath ".`nPress CapsLock-Alt-Y To See It.`nPress CapsLock-Ctrl-Y To Copy It's FilePath.")
        SetTimer, % F_SK, -1
    }
    Return

CapsLock::
    Suspend, Permit
    ToggleExistingCapsLockStateToPermState()
    Return

CapsLock & F2::
    Suspend, Permit
*F2::
    Global F_S_M_HK_Enabled, M_HK_Disabled, C_HK_Toggle
    If (A_IsSuspended) {
        SetTimer, % F_S_M_HK_Enabled, 500
    } else {
        SetTimer, % F_S_M_HK_Enabled, Off
        ShowTip(M_HK_Disabled, C_HK_Toggle, True)
    }
    Suspend
    Return

CapsLock & Tab::
    Suspend, Permit
Tab::
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

/*
CapsLock & '::
    Suspend, Permit
*'::
    Global CaseChangeState, CaseChangeText, ExpectedClipBoardUpdateTime
    ShowKey("Capitalise Selected Text Cycling Through,`n1st Caps -> All Caps -> All Smalls -> Original.")
    If (CaseChangeState = "0") {
        ShowKey("Capitalise 1st Letters.")
        SendInput ^{Insert}
        Sleep ExpectedClipBoardUpdateTime
        CaseChangeText := ClipBoard
        If (StrLen(CaseChangeText) = 0)
            Return
        CaseChangeState := 1
        StringUpper ClipText, CaseChangeText, T
    } else If (CaseChangeState = "1") {
        ShowKey("Capitalise All Letters.")
        StringUpper ClipText, CaseChangeText
        CaseChangeState := 2
    } else If (CaseChangeState = "2") {
        ShowKey("Lowercase All Letters.")
        StringLower ClipText, CaseChangeText
        CaseChangeState := 3
    } else {
        ShowKey("Restore Original Text.")
        ClipText := CaseChangeText
        CaseChangeState := 0
    }
    ClipBoardPutSync(ClipText)
    NBS := StrLen(CaseChangeText)
    SendInput {BackSpace %NBS%}+{Insert}
    SetTimer, ResetCaseChangeState, -7000
    Return
*/

ResetCaseChangeState:
    Global CaseChangeState, CaseChangeText
    CaseChangeState := 0
    CaseChangeText := ""
    Return

CapsLock & BackSpace::
    Suspend, Permit
*BackSpace::
    Global ClipStackCurr, ClipStack, FP_ClipTexts
    ShowKey("Clear ClipBoard History.")
    ShowTipClipBoard("ClipBoard History Cleared.")
    ClipStackCurr := 0
    ClipStack := []
    ClipBoardPutSync("")
    FileDelete, % FP_ClipTexts "\*.txt"
    Return

CapsLock & \::
    Suspend, Permit
*\::
    Global ClipStackCurr, ClipStack
    ShowKey("Forget Current ClipBoard Text From History.")
    If (ClipStackCurr = "0") {
        Return
    }
    ShowTipClipBoard("Forgetting ..`n`nClipText#" ClipStackCurr ":`n" ClipStack[ClipStackCurr])
    ClipStack.RemoveAt(ClipStackCurr)
    ClipStackCurr := Min(ClipStackCurr, ClipStack.Count())
    SetTimer, ClipBoardPopulate, -1
    Return

NoOp_SP:
    Suspend, Permit
    Return

NoOp:
    Return

ClipBoardPrev() {
    Global ClipStackCurr, ClipStack
    ShowKey("Set ClipBoard To Text Copied Earlier.")
    If (ClipStackCurr = "0") {
        Return
    }
    ClipStackCurr := ClipStackCurr == "1" ? ClipStack.Count() : (ClipStackCurr - 1)
    ShowTipClipBoard("ClipText#" ClipStackCurr ":`n" ClipStack[ClipStackCurr], !GetKeyState("Alt"))
    SetTimer, ClipBoardPopulate, -1
    Return
}
CapsLock & q::
    Suspend, Permit
*q::
    ClipBoardPrev()
    Return
CapsLock & WheelUp::
CapsLock & WheelLeft::
ClipBoardPrevLabel_SP:
    Suspend, Permit
    ClipBoardPrev()
    WheelsPrevDisable()
    Return
*WheelUp::
*WheelLeft::
ClipBoardPrevLabel:
    ClipBoardPrev()
    WheelsPrevDisable()
    Return
WheelsPrevDisable() {
    If !GetKeyState("Ctrl") Return
    Global NextScrollWaitTime
    HotKey, *WheelUp, NoOp
    HotKey, *WheelLeft, NoOp
    HotKey, CapsLock & WheelUp, NoOp_SP
    HotKey, CapsLock & WheelLeft, NoOp_SP
    SetTimer, WheelsPrevEnable, % -NextScrollWaitTime
}
WheelsPrevEnable() {
    HotKey, *WheelUp, ClipBoardPrevLabel
    HotKey, *WheelLeft, ClipBoardPrevLabel
    HotKey, CapsLock & WheelUp, ClipBoardPrevLabel_SP
    HotKey, CapsLock & WheelLeft, ClipBoardPrevLabel_SP
}

ClipBoardNext() {
    Global ClipStackCurr, ClipStack
    ShowKey("Set ClipBoard To Text Copied Later.")
    If (ClipStackCurr = "0") {
        Return
    }
    ClipStackCurr := ClipStackCurr == ClipStack.Count() ? 1 : (ClipStackCurr + 1)
    ShowTipClipBoard("ClipText#" ClipStackCurr ":`n" ClipStack[ClipStackCurr], !GetKeyState("Alt"))
    SetTimer, ClipBoardPopulate, -1
    Return
}
CapsLock & e::
    Suspend, Permit
*e::
    ClipBoardNext()
    Return
CapsLock & WheelDown::
CapsLock & WheelRight::
ClipBoardNextLabel_SP:
    Suspend, Permit
    ClipBoardNext()
    WheelsNextDisable()
    Return
*WheelDown::
*WheelRight::
ClipBoardNextLabel:
    ClipBoardNext()
    WheelsNextDisable()
    Return
WheelsNextDisable() {
    If !GetKeyState("Ctrl") Return
    Global NextScrollWaitTime
    HotKey, *WheelDown, NoOp
    HotKey, *WheelRight, NoOp
    HotKey, CapsLock & WheelDown, NoOp_SP
    HotKey, CapsLock & WheelRight, NoOp_SP
    SetTimer, WheelsNextEnable, % -NextScrollWaitTime
}
WheelsNextEnable() {
    HotKey, *WheelDown, ClipBoardNextLabel
    HotKey, *WheelRight, ClipBoardNextLabel
    HotKey, CapsLock & WheelDown, ClipBoardNextLabel_SP
    HotKey, CapsLock & WheelRight, ClipBoardNextLabel_SP
}


CapsLock & z::
CapsLock & MButton::
    Suspend, Permit
*z::
*MButton::
    Global ClipStackCurr, ClipStack, DisableClipBoardMsgs
    DisableClipBoardMsgs := !DisableClipBoardMsgs
    Msg := ""
    If (ClipStackCurr = "0") {
        Msg := Msg "`nClipBoard Empty."
    } Else {
        Msg := Msg "`nTotal " ClipStack.Count() " ClipTexts Remembered."
        Msg := Msg "`n`nCurrently On ClipText#" ClipStackCurr ":`n" ClipStack[ClipStackCurr]
    }
    If (DisableClipBoardMsgs) {
        Msg := "ClipBoard Notifications Disabled."
        HideTipClipBoard()
        ShowTipArbitrary(Msg)
    } Else {
        Msg := "ClipBoard Notifications Enabled." Msg
        HideTipArbitrary()
        ShowTipClipBoard(Msg)
    }
    SetTimer, ClipBoardPopulate, -1
    Return

ClipBoardPopulate() {
    Global ClipStackCurr, ClipStack
    If (ClipStackCurr == "0")
        ClipBoardPutSync("")
    Else
        ClipBoardPutSync(ClipStack[ClipStackCurr])
}

ClipBoardListener(ClipContentType) {
    Global ClipStackCurr, ClipStack, DisableClipBoardListener
    If (DisableClipBoardListener) {
        Return
    }
    ClipText := ClipBoard
    If (ClipContentType != "1" or ClipText == "") {
        Return
    }
    Loop % ClipStack.Count()
    {
        If (ClipText == ClipStack[A_Index]) {
            ShowTipClipBoard("ClipText Already Present.`n`n" "ClipText#" A_Index ":`n" ClipText)
            ClipStackCurr := A_Index
            Return
        }
    }
    ClipStack.Push(ClipText)
    ClipStackCurr := ClipStack.Count()
    ShowTipClipBoard("ClipText#" ClipStackCurr ":`n" ClipStack[ClipStackCurr])
}

ExitSub() {
    Suspend, Permit
    Global FuncOfW, DisableClipBoardMsgs, ClipStackCurr, ShowKeysOn, AltTab, RmConfigOnExit
    Global FP_ClipTexts, FP_Variables
    If (RmConfigOnExit) {
        FileDelete, % FP_Variables "\*.txt"
        FileDelete, % FP_ClipTexts "\*.txt"
        ShowTipArbitrary("Configuration Deleted.")
    } Else {
        ConfigSet("FuncOfW", FuncOfW)
        ConfigSet("DisableClipBoardMsgs", DisableClipBoardMsgs)
        ConfigSet("ClipStackCurr", ClipStackCurr)
        ConfigSet("ShowKeysOn", ShowKeysOn)
        ConfigSet("AltTab", AltTab)
        ConfigSet("ToolTipCoOrdX", ToolTipCoOrdX)
        ConfigSet("ToolTipCoOrdY", ToolTipCoOrdY)
        SaveClipBoardHistoryOnDisk()
        ShowTipArbitrary("Configuration Saved.")
    }
    ShowTipArbitrary("Exiting HotKeys App ..")
    Return
}

SaveClipBoardHistoryOnDisk() {
    Global FP_ClipTexts, ClipStackCurr, ClipStack, FP_ClipTexts
    FileDelete, % FP_ClipTexts "\*.txt"
    If (ClipStackCurr = "0") {
        ShowTipClipBoard("No ClipTexts To Save On The Disk!")
        Return False
    }
    Loop % ClipStack.Count()
    {
        FileAppend, % ClipStack[A_Index], % FP_ClipTexts "\" A_Index ".txt"
    }
    ShowTipClipBoard("ClipTexts Saved.")
    Return True
}

LoadClipBoardHistoryOffOfDisk() {
    Global ClipStack, FP_ClipTexts
    ClipStack := []
    K := 1
    FP := ""
    ClipText := ""
    While (True) {
        FP := FP_ClipTexts "\" K ".txt"
        If FileExist(FP) {
            FileRead, ClipText, % FP
            ClipStack.Push(ClipText)
            K += 1
        } Else {
            Return
        }
    }
}

ClipBoardPutSync(ByRef text) {
    Global DisableClipBoardListener, ExpectedClipBoardUpdateTime
    DisableClipBoardListener := True
    ClipBoard := text
    Sleep %ExpectedClipBoardUpdateTime%
    DisableClipBoardListener := False
}

CapsLock & `::
    Suspend, Permit
*`::
    ShowKey("Show The Remembered CliBoard Texts In NotePad++.")
    SetTimer, LaunchClipTextsInNotePadPP, -1
    Return

LaunchClipTextsInNotePadPP() {
    Global FP_ClipTexts, ClipStackCurr
    If SaveClipBoardHistoryOnDisk() {
        Run, % """C:\Program Files\Notepad++\notepad++.exe"" -multiInst -nosession """ FP_ClipTexts "\*.txt"" """ FP_ClipTexts "\" ClipStackCurr ".txt"""
    }
}

CapsLock & m::
    Suspend, Permit
*m::
    SwapFuncOfMovementKeys()
    ShowKey((FuncOfW == "DoUp" ? "WASD" : "HJKL") " Are Now The Arrow Keys")
    Return

CapsLock & F12::
    Suspend, Permit
*F12::
    Global RmConfigOnExit
    RmConfigOnExit := True
    ExitSub()
    Reload
    Return

CapsLock & N::
    Suspend, Permit
*N::
    Global ShowLastNotif, LastToolTipText, LastToolTipID, C_M_LastToolTip
    CallTipHider(LastToolTipID)
    If (ShowLastNotif) {
        ShowLastNotif := False
        ShowTip(LastToolTipText, C_M_LastToolTip, False)
    } Else {
        ShowLastNotif := True
        CallTipHider(C_M_LastToolTip)
    }
    Return

CapsLock & P::
    Suspend, Permit
*P::
    Global ToolTipCoOrdX, ToolTipCoOrdY, LastToolTipText, LastToolTipID
    If (ToolTipCoOrdX = 0 && ToolTipCoOrdY = 0) {
        ToolTipCoOrdX := A_ScreenWidth
        ToolTipCoOrdY := 0
    } Else If (ToolTipCoOrdX = A_ScreenWidth  && ToolTipCoOrdY = 0) {
        ToolTipCoOrdX := A_ScreenWidth
        ToolTipCoOrdY := A_ScreenHeight
    } Else If (ToolTipCoOrdX = A_ScreenWidth && ToolTipCoOrdY = A_ScreenHeight) {
        ToolTipCoOrdX := 0
        ToolTipCoOrdY := A_ScreenHeight
    } Else If (ToolTipCoOrdX = 0 && ToolTipCoOrdY = A_ScreenHeight) {
        CoordMode, Mouse, Screen
        MouseGetPos X, Y
        ToolTipCoOrdX := X
        ToolTipCoOrdY := Y
    } Else {
        ToolTipCoOrdX := 0
        ToolTipCoOrdY := 0
    }
    ShowTip(LastToolTipText, LastToolTipID, True)
    Return

RmLF(ByRef Str) {
    StringReplace, Str, Str, `r, , All
    StringReplace, Str, Str, `n, , All
    Return Str
}

CheckForUpdates() {
    Global Version, LatestVersionURL, HotKeysExeDLURL
    ShowTipArbitrary("Please Wait!`nChecking If An Update Is Available.")
    LatestVersion := Version
    Try {
        LatestVersion := RmLF(HttpGet(LatestVersionURL))
        ; MsgBox, % LatestVersion " <= " Version " ? " (LatestVersion <= Version)
    } Catch {
        ShowTipArbitrary("Couldn't Retrieve Latest Version!")
        Return
    }
    If (LatestVersion <= Version) {
        ShowTipArbitrary("Cheers!`nAlready Running The Latest Version Of HotKeys!")
        Return
    } Else {
        MsgBox, 4, % "Update On Checking On Update!", % "An Update Is Available. Want To Try It?"
        IfMsgBox, No
            Return
        IfMsgBox, TimeOut
            Return
        ShowTipArbitrary("Hold On Please!`nDownloading The Latest Version Of HotKeys.")
        DLFile(HotKeysExeDLURL, A_ScriptFullPath ".Latest", True)
        ExitSub()
        Run, PowerShell "Echo 'Downloaded The Latest Version. `nNow Overwriting The Old Version.'; Sleep 3; Move-Item -Path '%A_ScriptFullPath%.Latest' -Destination '%A_ScriptFullPath%' -Force; Start-Process -FilePath '%A_ScriptFullPath%' -ArgumentList '-ShowMsgUpdated';"
        ExitApp
    }
}

HttpGet(URL) {
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", URL, True)
    req.Send()
    req.WaitForResponse()
    Return req.ResponseText
}

DLFile(URL, FP, OW) { ; DL=Download, FP=FilePath, OW=OverWrite
    req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    req.Open("HEAD", URL, False)
    req.Send()
    size_total := req.GetResponseHeader("Content-Length")
    LastSize := 0
    LastSizeTick := A_TickCount
    ProgressUpdater := Func("DLProgress").Bind(URL, FP, size_total)
    SetTimer, % ProgressUpdater, 1000
    URLDownloadToFile, % URL, % FP
}

DLProgress(ByRef URL, ByRef FP, ByRef FinalSize) {
    Global C_M_Arbitrary, LastSizeTick, LastSize
    If !FileExist(FP) Return
    CurrentSize := 0
    FileGetSize, CurrentSize, % FP
    CurrentSizeTick := A_TickCount ; Ticks are at milliseconds
    MBps := (((CurrentSize - LastSize) / 1048576) / ((CurrentSizeTick - LastSizeTick) / 1000))
    LastSize := CurrentSize
    LastSizeTick := CurrentSizeTick
    PercentDone := (CurrentSize / FinalSize * 100)
    If (PercentDone = 100)
        CallTipHider(C_M_Arbitrary)
    Else
        ShowTipArbitrary("Downloading,`n    " URL "`n`nSpeed,`n    " MBps " MBps`n`nDownloaded,`n    " (CurrentSize / 1048576) " / " (FinalSize / 1048576) " MB (" PercentDone "%)")
}

CapsLock & LButton::
    Suspend, Permit
*LButton::
    If GetKeyState("Alt") {
        SendInput {LButton}+{Insert}
    } Else If GetKeyState("Ctrl") {
        SendInput {LButton 2}+{Insert}
    } Else If GetKeyState("Shift") {
        SendInput {LButton}^{Home}{Shift Down}^{End}{Shift Up}+{Insert}
    } Else {
        SendInput +{Insert}
    }
    Return

CapsLock & RButton::
    Suspend, Permit
*RButton::
    If GetKeyState("Alt") {
        SendInput {LButton}%ClipBoard%
    } Else If GetKeyState("Ctrl") {
        SendInput {LButton 2}%ClipBoard%
    } Else If GetKeyState("Shift") {
        SendInput {LButton}^{Home}{Shift Down}^{End}{Shift Up}%ClipBoard%
    } Else {
        SendInput %ClipBoard%
    }
    Return

