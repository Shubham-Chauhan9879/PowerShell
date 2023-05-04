# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
# Create a new form
$Form1 = New-Object system.Windows.Forms.Form
# Define the size, title and background color
$Form1.ClientSize = ‘500,250’
$Form1.text = “RSAT Tool Installer”
$Form1.BackColor = “#fffff1”
$List = New-Object system.Windows.Forms.ComboBox
$List.text = “”
$List.width = 400
$List.autosize = $true

# Add install button
$Install = New-Object System.Windows.Forms.Button
$Install.Location = New-Object System.Drawing.Point(20,200)
$Install.Size = New-Object System.Drawing.Size(75,23)
$Install.Text = 'Install'
$Install.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form1.AcceptButton = $Install
$form1.Controls.Add($Install)

# Add Uninstall button
$Uninstall = New-Object System.Windows.Forms.Button
$Uninstall.Location = New-Object System.Drawing.Point(400,200)
$Uninstall.Size = New-Object System.Drawing.Size(75,23)
$Uninstall.Text = 'Uninstall'
$Uninstall.DialogResult = [System.Windows.Forms.DialogResult]::No
$form1.AcceptButton = $Uninstall
$form1.Controls.Add($Uninstall)

# Add the items in the dropdown list
@('Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
'Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0',
'Rsat.CertificateServices.Tools~~~~0.0.1.0',
'Rsat.DHCP.Tools~~~~0.0.1.0',
'Rsat.Dns.Tools~~~~0.0.1.0',
'Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0',
'Rsat.FileServices.Tools~~~~0.0.1.0',
'Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0',
'Rsat.IPAM.Client.Tools~~~~0.0.1.0',
'Rsat.LLDP.Tools~~~~0.0.1.0',
'Rsat.NetworkController.Tools~~~~0.0.1.0',
'Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0',
'Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0',
'Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0',
'Rsat.ServerManager.Tools~~~~0.0.1.0',
'Rsat.Shielded.VM.Tools~~~~0.0.1.0',
'Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0',
'Rsat.StorageReplica.Tools~~~~0.0.1.0',
'Rsat.SystemInsights.Management.Tools~~~~0.0.1.0',
'Rsat.VolumeActivation.Tools~~~~0.0.1.0',
'Rsat.WSUS.Tools~~~~0.0.1.0') | ForEach-Object {[void] $List.Items.Add($_)}
# Select the default value
$List.SelectedIndex = 0
$List.location = New-Object System.Drawing.Point(20,100)
$List.Font = ‘Microsoft Sans Serif,10’

 
#Add a label
$Description = New-Object system.Windows.Forms.Label
$Description.text = “Selected Tool: $selected”
$Description.AutoSize = $false
$Description.width = 450
$Description.height = 50
$Description.location = New-Object System.Drawing.Point(20,50)
$Description.Font = ‘Microsoft Sans Serif,10’

#Catch changes to the list

$List.add_SelectedIndexChanged({
$selected = $List.SelectedItem
#write-host $selected
$Description.text = “Selected Tool: $selected”

})


#Conditions

$Install.add_click(



   {

    <# Disable WSUServer value to 1 Run Windows Capability to directly download the components from internet Enable WSUServer value to 0 #>
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
    Restart-Service "Windows Update" -ErrorAction SilentlyContinue
    #Write-Host "Adding Components…" -ForegroundColor Green
    Get-WindowsCapability -Name $list.SelectedItem  -Online | Add-WindowsCapability -Online
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1
    Restart-Service "Windows Update" -ErrorAction SilentlyContinue
    write-host "Installed"


    }


)

$Uninstall.add_click(



{

Remove-WindowsCapability -Name $list.SelectedItem -Online
write-host "Uninstalled"


}




)



$Form1.Controls.Add($List)
$Form1.Controls.Add($Description)

# Display the form
[void]$Form1.ShowDialog()

