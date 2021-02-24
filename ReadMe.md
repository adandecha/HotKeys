Shorten traveling the keyboard to a measly 60%!

This is an AutoHotKey script to bind some very useful CapsLock hotkeys to the keyboard.

To have a look-see, download and run **[this](https://github.com/adandecha/HostedFilesPublic/raw/master/HotKeys.exe)**.
<br/>
To compile it manually, please read through the following.

**Setting things up:**

Download and extract [this](https://github.com/adandecha/HotKeys/archive/map2.zip).
<br/>
Run [Installer.bat](Installer.bat) as Admin.
<br/>
In detail, it does [these](Steps.txt) set of things.
<br/>
<br/>
Done!

**Using Hotkeys:**

```
CapsLock can be used as the modifier key to the HotKeys.
For example, to generate the BackSpace key, one can hit - CapsLock+I.

Following are all the HotKeys that can be used holding down CapsLock.
On the left is what's pressed, and on the right is what it results into.


Movement Keys:
-------- ----

A|H              : Left
D|L              : Right

W|K              : Up
S|J              : Down

H|A              : Home
L|D              : End

J|S              : PageDown
K|W              : PageUp

M                : Swap functionalities of movement keys WASD with KHJL

I                : Backspace
O                : Delete


ClipBoard Management Keys:
--------- ----------  ----

X                : Cut (Ctrl+X)
C                : Copy (Ctrl+C)

Q                : Reset clipboard to text copied earlier
E                : Reset clipboard to text copied later

V|LeftClick      : Pastes clipboard text (Performs, Shift+Insert)
Alt+LeftClick    : Single click and paste clipboard text (Performs, LeftCLick Shift+Insert)
Ctrl+LeftClick   : Double click and paste clipboard text (Performs, LeftCLick LeftCLick Shift+Insert)
Shift+LeftClick  : Select all text and paste clipboard text (Performs, LeftCLick Ctrl+Home ShiftDown Ctrl+End ShiftUp Shift+Insert)

T|RightClick     : Types in clipboard text (can be used where text is not allowed to be pasted)
Alt+LeftClick    : Single click and type in clipboard text (Before typing, it performs, LeftCLick)
Ctrl+LeftClick   : Double click and type in clipboard text (Before typing, it performs, LeftCLick LeftCLick)
Shift+LeftClick  : Select all and type in clipboard text (Before typing, it performs, LeftCLick Ctrl+Home ShiftDown Ctrl+End ShiftUp)

Z                : Show notifications when clipboard text changes
`                : Show the remembered cliboard texts in NotePad++ 64-bit (get it from notepad-plus-plus.org/downloads)

BackSpace        : Forget all the remembered clipboard texts
\                : Forget current clipboard text


Function Keys:
-------- ----

1                : F1
2                : F2
3                : F3
4                : F4
5                : F5
6                : F6
7                : F7
8                : F8
9                : F9
0                : F10
-                : F11
+                : F12


Media Keys:
----- ----

,                : Volume down
.                : Volume up
/                : Volume mute

Shift+,          : Previous track
Shift+.          : Next track
Shift+/          : Pause/play


Misc. Keys:
----  ----

[                : Project to PC screen only
]                : Project to second screen only

Y                : Save screenshot (Win+PrintScreen) on the disk
Alt-Y            : Show screenshot in explorer
Ctrl-Y           : Copy screenshot's full path

Tab              : Disable Alt+Tab functionality

U                : UnDo (Ctrl+Z)
R                : ReDo (Ctrl+Y)
F                : Find (Ctrl+F)

;                : Do a left click
'                : Opens context menu


Notification Management Keys:
------------ ---------- ----

N                : Show the last notification that HotKeys gave
P                : Cycle showing notifications from top left, to top right, bottom right,
                   bottom left, and at the mouse pointer; go to all corners clock-wise.
F1               : Show help for each HotKey pressed


Program Management Keys:
------- ---------- ----

F2               : Enable all the HotKeys without the need of holding down the CapsLock
F4               : Exit the HotKeys app
F12              : Clean restart the HotKeys app forgetting all config except clipboard history

Alt-U            : Check for Updates, and request User to install, if available.

```

To give a consistent experience across restarts, some settings are saved on the disk,
in a similarly named .ini file where the script is located.
It remembers following things,
```
01. WASD are the Arrow keys or HJKL are.
02. Alt+Tab is to be allowed or not.
03. What copied text was actually used last among many remembered.
04. Where and if at all, the notifications are to be displayed.
```

**Also,**

LWin, LAlt, and RAlt are the keys which keyboard manufacturers don't move around mostly.
<br/>
One can remap ~~LCtrl~~->_LWin_, ~~LWin~~->_LCtrl_, and ~~RAlt~~->_RWin_, by running,
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Remap_LC2LW_LW2LC_RA2RW.reg](Remap_LC2LW_LW2LC_RA2RW.reg), and restarting Windows.
<br/>
It can be restored by running,
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Restore_LC_LW_RA.reg](Restore_LC_LW_RA.reg), and restarting Windows.
<br/>
<br/>
For the first time users, I've got some suggestions [here](Suggestions.md)!
<br/>
<br/>
**Enjoy!**

