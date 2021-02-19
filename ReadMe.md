Shorten traveling the keyboard to a measly 60%!

This is an AutoHotKey script to bind some very useful CapsLock hotkeys to the keyboard.

To have a look and feel, an already compiled executable can be found **[here](https://drive.google.com/open?id=1l-_ly_VcWkBHzeugyiI1za9_tW2-sLh9)**.
<br/>
To build/compile it manually please read through the following.

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


A         : Left        : H
D         : Right       : L

W         : Up          : K
S         : Down        : J

H         : Home        : A
L         : End         : D

J         : PageDown    : S
K         : PageUp      : W

M         : Swap functionalities of movement keys WASD with KHJL


I         : Backspace
O         : Delete


X         : Cut (Ctrl+X)
C         : Copy (Ctrl+C)

V         : Paste (Shift+Insert)
T         : Type in clipboard text (can be used where text is not allowed to be pasted)

Z         : Show/hide notifications when clipboard text changes
`         : Show the remembered cliboard texts in NotePad++ 64-bit

Q         : Reset clipboard to text copied earlier
E         : Reset clipboard to text copied later

BackSpace : forget all the remembered clipboard texts
\         : Forget current clipboard text


U         : UnDo (Ctrl+Z)
R         : ReDo (Ctrl+Y)
F         : Find (Ctrl+F)


;         : Do a left click
'         : Opens context menu


1         : F1
2         : F2
3         : F3
4         : F4
5         : F5
6         : F6
7         : F7
8         : F8
9         : F9
0         : F10
-         : F11
+         : F12


,         : Volume down
Shift+,   : Previous track

.         : Volume up
Shift+.   : Next track

/         : Volume mute
Shift+/   : Pause/play


[         : Project to PC screen only
]         : Project to second screen only

Y         : Save screenshot (Win+PrintScreen) on the disk
Alt-Y     : Show screenshot in explorer
Ctrl-Y    : Copy screenshot's full path

Tab       : Disable Alt+Tab functionality

N         : Show/hide the last notification that HotKeys gave

F1        : Show/hide help for each HotKey pressed
F4        : Exit the HotKeys app
F12       : Clean restart the HotKeys app forgetting all config except clipboard history

```

To give a consistent experience across restarts, some settings are saved on the disk,
in a similarly named .ini file where the script is located.
It remembers following things,
```
01. Alt+Tab is to be allowed or not.
02. WASD are arrow keys or HJKL are.
03. What text was on the clipboard among many remembered.
04. Notifications are to be displayed or not.
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
**Enjoy!**

