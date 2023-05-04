$DriveSpace = Get-PSDrive -Name C  ##variable to get the details of C drive
 
$DriveFreeSpace = ($DriveSpace.Free)/1Mb ##to get free space in Mb
 
$Initial = $DriveFreeSpace * (.3)  ##initial value will be set to 30% of free diskspace
 
$Maximum = $DriveFreeSpace * (.6) ##Maximum value will be set to 60% of free diskspace
 
$pagefile = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
$pagefile.AutomaticManagedPagefile = $false
$pagefile.put() | Out-Null
$pagefileset = Get-WmiObject Win32_pagefilesetting
$pagefileset.InitialSize = $Initial    ##setting the initial size
$pagefileset.MaximumSize = $Maximum    ##setting the Maximum size
$pagefileset.Put() | Out-Null
