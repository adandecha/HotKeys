@Echo Off
CD /D "%~dp0"
Call :InstallAHK 2> NUL || (
    Echo AutoHotkey Compiler Missing!
    Pause
    Exit /B 1
)
MkDir "%ProgramFiles%\HotKeys" 2> NUL
Erase /F "%ProgramFiles%\HotKeys\HotKeys.ahk" 2> NUL
Copy /Y HotKeys.ahk "%ProgramFiles%\HotKeys\HotKeys.ahk" 2> NUL
SchTasks /CREATE /F /TN HotKeys /XML Task.xml 2> NUL
Explorer AddShortcut.vbs 2> NUL
Start "" "%ProgramFiles%\HotKeys\HotKeys.ahk" 2> NUL
Echo HotKeys Installed.
Pause
Exit /B 0

:InstallAHK
Echo Installing AutoHotkey,
Reg Query HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Open\Command 2> NUL && Echo Done. && Exit /B 0
PowerShell -Command "Invoke-WebRequest https://www.autohotkey.com/download/ahk-install.exe -OutFile AHKInstaller.exe"
AHKInstaller.exe /S || Exit /B 1
Echo Done.
Exit /B 0

