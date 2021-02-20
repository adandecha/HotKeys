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

CfgPath := A_ScriptFullPath ".ini"
RmConfigOnExit := False

RegRead, ScreenshotsDir, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders, {B7BEDE81-DF94-4682-A7D8-57A52620B86F}, % UserProfile "\Pictures\Screenshots"
ScreenshotsDir := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c <nul set /p=" ScreenshotsDir).StdOut.ReadAll()

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
C_M_ClipBoard := 6
C_M_LastToolTip := 7

ShowLastNotif := True
IniRead, ToolTipCoOrdX, %CfgPath%, Globals, ToolTipCoOrdX, 0
IniRead, ToolTipCoOrdY, %CfgPath%, Globals, ToolTipCoOrdY, 0
LastShowTipCall := ""
LastToolTipText := ""

F_H_M_On_Load := Func("HideTip").Bind(C_On_Load)
F_H_M_Caps_Toggle := Func("HideTip").Bind(C_Caps_Toggle)
F_H_M_HK_Toggle := Func("HideTip").Bind(C_HK_Toggle)
F_H_M_Key_Press := Func("HideTip").Bind(C_Key_Press)
F_H_M_Arbitrary := Func("HideTip").Bind(C_M_Arbitrary)
F_H_M_ClipBoard := Func("HideTip").Bind(C_M_ClipBoard)

IniRead, ShowKeysOn, %CfgPath%, Globals, ShowKeysOn, % False

LogKeyPresses := False

IniRead, AltTab, %CfgPath%, Globals, AltTab, % True

CaseChangeState := 0
CaseChangeText := ""

KeepExistingCapsLockStateButToPermState()

ShowTip(M_On_Load, C_On_Load, F_H_M_On_Load, True)

ExpectedClipBoardUpdateTime := 200

ClipStack := []
Loop, Files, %A_Temp%\ClipText*.txt
{
    FileRead, ClipText, %A_LoopFileFullPath%
    ClipStack.Push(ClipText)
    FileDelete, %A_LoopFileFullPath%
}
IniRead, ClipCurrIdx, %CfgPath%, Globals, ClipCurrIdx, % ClipStack.Count()
OnExit ExitSub
OnClipBoardChange("ClipBoardListener")
IniRead, DisableClipBoardMsgs, %CfgPath%, Globals, DisableClipBoardMsgs, % True
DisableClipBoardListener := False
SetTimer, ClipBoardPopulate, -1

; Command params do store quotes if used around literal strings of arguments
; you have to force and expr evaluation if wanted just like around %CfgPath%
IniRead, FuncOfW, %CfgPath%, Globals, FuncOfW, DoUp
; need to force use parentheses around comparision exact format isdu
; need to use var w/o %% on LHS and quotes around DoUp as it has become an expr
; read explanation01 which is about using quotes in an expr
SetWASDHJKL((FuncOfW == "DoUp"))

Suspend, On

Return

SwapFuncOfMovementKeys() {
    Global FuncOfW
    SetWASDHJKL((FuncOfW != "DoUp"))
}

SetWASDHJKL(FuncOfW_Is_To_DoUp) {
    Global FuncOfW, FuncOfA, FuncOfS, FuncOfD, FuncOfH, FuncOfJ, FuncOfK, FuncOfL
    If (FuncOfW_Is_To_DoUp) {
        ; explanation01
        ; := RHS considered expr and evaluated so if "DoUp" don't have quotes around it
        ; DoUp would be evaluated to be 1st use of a var not declared before and thus
        ; it's value would be "" and thus FuncOfW would store "" in it
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

ShowTipArbitrary(ByRef Msg, ByRef VisibilityTimePeriod := 1000) {
    Global C_M_Arbitrary, F_H_M_Arbitrary
    ShowTip(Msg, C_M_Arbitrary, F_H_M_Arbitrary, True, VisibilityTimePeriod)
    Return
}

ShowTipClipBoard(ByRef Msg, ByRef VisibilityTimePeriod := 3000) {
    Global C_M_ClipBoard, F_H_M_ClipBoard, DisableClipBoardMsgs
    If DisableClipBoardMsgs {
        %F_H_M_ClipBoard%()
        Return
    }
    ShowTip(Msg, C_M_ClipBoard, F_H_M_ClipBoard, True, VisibilityTimePeriod)
    Return
}

HideTip(ByRef Id) {
    ToolTip, , , , % Id
    Return
}

ShowTip(ByRef Text, ByRef ConstID, ByRef HiderFunc, ByRef ShowTemporarily, ByRef VisibilityTimePeriod := 2000) {
    Global LastToolTipText, LastShowTipCall
    Global ToolTipCoOrdX, ToolTipCoOrdY
    LastToolTipText := Text
    LastShowTipCall := Func("ShowTip").Bind(Text, ConstID, HiderFunc, ShowTemporarily, VisibilityTimePeriod)

    ToolTip, % Text, % ToolTipCoOrdX, % ToolTipCoOrdY, % ConstID

    If (ShowTemporarily)
        SetTimer, % HiderFunc, -%VisibilityTimePeriod%
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

RCtrl::
    Suspend
    If (A_IsSuspended) {
        ShowTip(M_Disabled, C_HK_Toggle, F_H_M_HK_Toggle, True)
    } else {
        ; ContinuouslyPopUpHotKeysEnabledMsg := Func("ShowTip").Bind(M_Enabled, C_HK_Toggle, F_H_M_HK_Toggle, False)
        ; SetTimer, % ContinuouslyPopUpHotKeysEnabledMsg, 500
        OverlayCapsLockStatusMessage()
    }
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
    Global ClipCurrIdx, ClipStack
    ShowKey("Clear ClipBoard History.")
    ShowTipClipBoard("ClipBoard History Cleared.")
    ClipCurrIdx := 0
    ClipStack := []
    ClipBoardPutSync("")
    FileDelete, %A_Temp%\ClipText*.txt
    Return

CapsLock & \::
    Suspend, Permit
*\::
    Global ClipCurrIdx, ClipStack
    ShowKey("Forget Current ClipBoard Text From History.")
    If (ClipCurrIdx = "0") {
        Return
    }
    i := SubStr("0000000000" . ClipCurrIdx, -9)
    ShowTipClipBoard("Forgetting ..`n`nClipText#" i ":`n" ClipStack[ClipCurrIdx])
    ClipStack.RemoveAt(ClipCurrIdx)
    ClipCurrIdx := Min(ClipCurrIdx, ClipStack.Count())
    SetTimer, ClipBoardPopulate, -1
    Return

CapsLock & q::
    Suspend, Permit
*q::
    Global ClipCurrIdx, ClipStack
    ShowKey("Set ClipBoard To Text Copied Earlier.")
    If (ClipCurrIdx = "0") {
        Return
    }
    ClipCurrIdx := ClipCurrIdx == "1" ? ClipStack.Count() : (ClipCurrIdx - 1)
    i := SubStr("0000000000" . ClipCurrIdx, -9)
    ShowTipClipBoard("ClipText#" i ":`n" ClipStack[ClipCurrIdx])
    SetTimer, ClipBoardPopulate, -1
    Return

CapsLock & e::
    Suspend, Permit
*e::
    Global ClipCurrIdx, ClipStack
    ShowKey("Set ClipBoard To Text Copied Later.")
    If (ClipCurrIdx = "0") {
        Return
    }
    ClipCurrIdx := ClipCurrIdx == ClipStack.Count() ? 1 : (ClipCurrIdx + 1)
    i := SubStr("0000000000" . ClipCurrIdx, -9)
    ShowTipClipBoard("ClipText#" i ":`n" ClipStack[ClipCurrIdx])
    SetTimer, ClipBoardPopulate, -1
    Return

CapsLock & z::
    Suspend, Permit
*z::
    Global ClipCurrIdx, ClipStack, DisableClipBoardMsgs
    ShowKey((DisableClipBoardMsgs ? "Show" : "Hide") " Notifications For ClipBoard Changes.")
    DisableClipBoardMsgs := !DisableClipBoardMsgs
    Msg := "ClipBoard Notifications " (DisableClipBoardMsgs ? "Disabled." : "Enabled.")
    If (ClipCurrIdx = "0") {
        ShowTipArbitrary(Msg "`nClipBoard Text History Empty.")
    } Else {
        i := SubStr("0000000000" . ClipCurrIdx, -9)
        ShowTipClipBoard(Msg "`n`nTotal " ClipStack.Count() " ClipText(s) Remembered.`nCurrently On,`nClipText#" i ":`n" ClipStack[ClipCurrIdx])
        SetTimer, ClipBoardPopulate, -1
    }
    Return

ClipBoardPopulate() {
    Global ClipCurrIdx, ClipStack
    If (ClipCurrIdx == "0")
        ClipBoardPutSync("")
    Else
        ClipBoardPutSync(ClipStack[ClipCurrIdx])
}

ClipBoardListener(ClipContentType) {
    Global ClipCurrIdx, ClipStack, DisableClipBoardListener
    If (DisableClipBoardListener) {
        ; ShowTipClipBoard(A_LineNumber ": ClipBoard updated by self.`n" )
        Return
    }
    ClipText := ClipBoard
    If (ClipContentType != "1" or ClipText == "") {
        ; ShowTipClipBoard(A_LineNumber ": Empty or non-text ClipBoard.`n" )
        Return
    }
    Loop % ClipStack.Count()
    {
        If (ClipText == ClipStack[A_Index]) {
            i := SubStr("0000000000" . A_Index, -9)
            ; ShowTipClipBoard(A_LineNumber ": ClipText Already Present.`n" "ClipText#" i ":`n" ClipText)
            ShowTipClipBoard("ClipText Already Present.`n" "ClipText#" i ":`n" ClipText)
            ClipCurrIdx := A_Index
            Return
        }
    }
    ClipStack.Push(ClipText)
    ClipCurrIdx := ClipStack.Count()
    i := SubStr("0000000000" . ClipCurrIdx, -9)
    ShowTipClipBoard("ClipText#" i ":`n" ClipStack[ClipCurrIdx])
}

ExitSub:
    Suspend, Permit
    Global FuncOfW, DisableClipBoardMsgs, ClipCurrIdx, ShowKeysOn, AltTab, RmConfigOnExit
    If (RmConfigOnExit) {
        FileDelete, %CfgPath%
        FileDelete, %A_Temp%\ClipText*.txt
    } Else {
        SaveClipBoardHistoryOnDisk()
        IniWrite, %FuncOfW%, %CfgPath%, Globals, FuncOfW
        IniWrite, %DisableClipBoardMsgs%, %CfgPath%, Globals, DisableClipBoardMsgs
        IniWrite, %ClipCurrIdx%, %CfgPath%, Globals, ClipCurrIdx
        IniWrite, %ShowKeysOn%, %CfgPath%, Globals, ShowKeysOn
        IniWrite, %AltTab%, %CfgPath%, Globals, AltTab
        IniWrite, %ToolTipCoOrdX%, %CfgPath%, Globals, ToolTipCoOrdX
        IniWrite, %ToolTipCoOrdY%, %CfgPath%, Globals, ToolTipCoOrdY
    }
    ExitApp

SaveClipBoardHistoryOnDisk() {
    Global ClipCurrIdx, ClipStack
    FileDelete, %A_Temp%\ClipText*.txt
    If (ClipCurrIdx = "0") {
        ShowTipClipBoard("No ClipTexts To Save On The Disk!")
        Return False
    }
    SetFormat, Float, 06.0
    Loop % ClipStack.Count()
    {
        i := SubStr("0000000000" . A_Index, -9)
        FileAppend, % ClipStack[A_Index], %A_Temp%\ClipText%i%.txt
    }
    ShowTipClipBoard("Saved ClipText(s) At,`n" A_Temp "\ClipTextXXXXXXXXXX.txt File(s).")
    Return True
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
    If !SaveClipBoardHistoryOnDisk()
        Return
    SetTimer, LaunchClipTextsInNotePadPP, -500
    Return

LaunchClipTextsInNotePadPP() {
    Global ClipCurrIdx
    I := SubStr("0000000000" . ClipCurrIdx, -9)
    Run, "C:\Program Files\Notepad++\notepad++.exe" "-multiInst" "-nosession" "%A_Temp%\ClipText*.txt" "%A_Temp%\ClipText%I%.txt"
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
    Reload
    Return

CapsLock & N::
    Suspend, Permit
*N::
    Global ShowLastNotif, LastToolTipText, C_M_LastToolTip
    Global ToolTipCoOrdX, ToolTipCoOrdY
    If (ShowLastNotif) {
        ShowLastNotif := False
        ToolTip, % LastToolTipText, % ToolTipCoOrdX, % ToolTipCoOrdY, % C_M_LastToolTip
    } Else {
        ShowLastNotif := True
        ToolTip, , , , % C_M_LastToolTip
    }
    Return

CapsLock & P::
    Suspend, Permit
*P::
    Global ToolTipCoOrdX, ToolTipCoOrdY, LastShowTipCall
    If (ToolTipCoOrdX = 0 && ToolTipCoOrdY = 0) {
        ToolTipCoOrdX := A_ScreenWidth
        ToolTipCoOrdY := 0
    } Else
    If (ToolTipCoOrdX = A_ScreenWidth  && ToolTipCoOrdY = 0) {
        ToolTipCoOrdX := A_ScreenWidth
        ToolTipCoOrdY := A_ScreenHeight
    } Else
    If (ToolTipCoOrdX = A_ScreenWidth && ToolTipCoOrdY = A_ScreenHeight) {
        ToolTipCoOrdX := 0
        ToolTipCoOrdY := A_ScreenHeight
    } Else
    If (ToolTipCoOrdX = 0 && ToolTipCoOrdY = A_ScreenHeight) {
        ToolTipCoOrdX := A_ScreenWidth / 2
        ToolTipCoOrdY := A_ScreenHeight / 2
    } Else
    If (ToolTipCoOrdX = A_ScreenWidth / 2 && ToolTipCoOrdY = A_ScreenHeight / 2) {
        CoordMode, Mouse, Screen
        MouseGetPos X, Y
        ToolTipCoOrdX := X
        ToolTipCoOrdY := Y
    } Else {
        ToolTipCoOrdX := 0
        ToolTipCoOrdY := 0
    }
    ; hide CL-N notif
    ToolTip, , , , % C_M_LastToolTip
    ; re-show CL-F1 or CL-Z notifs
    LastShowTipCall.Call()
    Return

