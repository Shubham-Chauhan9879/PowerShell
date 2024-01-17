####################################################
#Sets Hash Directory and Generates HardwareHash file
####################################################
$CSVPath = new-item -Path "c:\" -Name "hhash" -ItemType Directory -Force
$serialnumber = Get-WmiObject win32_bios | select Serialnumber
Install-Script -Name Get-WindowsAutoPilotInfo -Force
Set-ExecutionPolicy Unrestricted -Force
Get-WindowsAutoPilotInfo -Outputfile $CSVPath\$($serialnumber.SerialNumber)-Hash.csv


######################################################
#Copy file to the server
######################################################

$ServerPAth = "\\ServerName\HWID"

Copy-Item -Path $CSVPath\$($serialnumber.SerialNumber)-Hash.csv -Destination $ServerPath -Recurse
