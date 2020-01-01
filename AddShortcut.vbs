Set shObj = CreateObject("WScript.Shell")
startUpPath = shObj.SpecialFolders("Startup")
set link = shObj.CreateShortcut(startUpPath + "\HotKeysTaskRunner.lnk")
link.TargetPath = "SchTasks.exe"
link.Arguments = "/RUN /TN HotKeys"
link.WindowStyle = 7
link.Save


