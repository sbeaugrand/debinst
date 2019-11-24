$file="$Home\Desktop\debian10vm.lnk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$file")
$Shortcut.TargetPath = "C:\Program Files\Git\git-bash.exe"
$Shortcut.WorkingDirectory = "$pwd"
$Shortcut.Save()
