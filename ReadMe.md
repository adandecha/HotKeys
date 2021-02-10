An AutoHotKey script to bind some very useful hotkeys to the keyboard.

**Setting things up:**

Download and install AutoHotKey from,
<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[autohotkey.com](https://www.autohotkey.com)
<br/>
<br/>
Run [Install.bat](Install.bat) as Admin.
<br/>
It adds HotKeys to Windows StartUp.
<br/>
In detail, it does [these](Steps.txt) set of things.
<br/>
<br/>
Done!

**Using Hotkeys:**

```
CapsLock can be used as the modifier key to the HotKeys.
For example, to generate the Home key, one can hit - CapsLock+A - keep CapsLock pressed and hit A.

RCtrl can used to toggle the HotKeys on or off.
For example, to generate the same Home key, one can also press keys - RCtrl A RCtrl.

Following is the list of HotKeys when used in conjuction with CapsLock or after RCtrl.
Left is what's pressed, and right is what it results into.

A   : Home
D   : End

W   : PageUp
S   : PageDown

H   : Left
L   : Right

K   : Up
J   : Down

I   : Backspace
O   : Delete

X   : Cut (Ctrl+X)
C   : Copy (Ctrl+C)

V   : Paste (Shift+Insert)
T   : Type in clipboard text (can be used where text is not allowed to be pasted)

U   : UnDo (Ctrl+Z)
R   : ReDo (Ctrl+Y)

F   : Find (Ctrl+F)
Y   : Save screenshot (Win+PrintScreen)

M   : Context menu
P   : Left click

Q   : Volume down
E   : Volume up

G   : Volume mute
Z   : Pause/play

B   : Previous track
N   : Next track

1   : F1
2   : F2
3   : F3
4   : F4
5   : F5
6   : F6
7   : F7
8   : F8
9   : F9
0   : F10
-   : F11
+   : F12

Tab : Disable Alt+Tab functionality.
.   : Switch case of selected text (capitalise 1st letters, all caps, all smalls, restore text)

[   : Project to PC screen only
]   : Project to second screen only

F1  : Show/hide help for each HotKey pressed.
F4  : Exit the HotKeys app.

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
An already compiled executable can be found **[here](https://drive.google.com/open?id=1l-_ly_VcWkBHzeugyiI1za9_tW2-sLh9)**.

**Enjoy!**

