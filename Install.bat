@Echo Off
CD /D "%~dp0"
"%ProgramFiles%/AutoHotkey/Compiler/Ahk2Exe.exe" /IN HotKeys.ahk /OUT "%UserProfile%/Documents/HotKeys.exe"
SchTasks /CREATE /F /TN HotKeys /XML Task.xml
Explorer AddShortcut.vbs
Start "" "%UserProfile%/Documents/HotKeys.exe"
Echo
Set /p dummy_var=Hit enter to continue ..

