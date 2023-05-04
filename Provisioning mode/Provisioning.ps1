$Check = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\CCM\CcmExec' -Name 'ProvisioningMode'
 
if ($Check -eq $true)
 
{
 

Invoke-WmiMethod -Namespace root\CCM -Class SMS_Client -Name SetClientProvisioningMode -ArgumentList $false
 
 
}
