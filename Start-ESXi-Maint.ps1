<#
ESXi maintenance script

March 2019
- Original version

May 4, 2019
- Amended to support ESXi host choices

May 8, 2019
- Set-VMStartPolicy is used to level-set auto-starts on VMs from host being rebooted
- Maint mode removed, as it blocks auto-start of VMs

May 10, 2019
-user/site/env specific variables now come from XML, amend settings.xml as required!

#>

$AllHostChoices = @()
$Esxihosts = ""
[XML]$VarXML = Get-content ".\Settings.xml "
$vCenter = $VarXML.Properties.Global.vMWARE.vCenter
$ADdomain = $VarXML.Properties.Global.ADdomain

[String]$Choices = ""

write-host "importing VMWARE PowerCLI modules. Please wait...."
write-host "`r`n"

IF (Get-Module -name vmware.powercli -ListAvailable) {

    Import-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue

}

Else {

    Write-warning "vSphere PowerCLI module not available. Please install via the below command:"
    write-host "Install-Module -Name VMware.PowerCLI -AllowClobber -force" -ForegroundColor cyan

}


Connect-VIServer -Server $vCenter -force
write-host "`r`n"

$esxihosts = Get-VMHost | Select -expand Name

ForEach ($esxihost in $esxihosts) {
   
   $Choice = read-Host -Prompt "Select Y to perform maintenance on esxi host $($esxihost). Select N to skip"
   
   $AllHostChoices += New-Object PSObject -property @{
        
        esxihost = $esxihost
        choice = $Choice
   }

}

$WorkList = $AllHostChoices | Where {$_.Choice -eq "Y"} | Select -expand esxihost

ForEach ($esxihost in $WorkList) {

    write-host "Level-setting current VMs on $esxihost to autostart"
    Get-VMhost -Name $esxihost | Get-VM | Get-VMStartPolicy | Where StartOrder -eq $NUll | Set-VMStartPolicy -StartAction PowerOn -StartDelay 30
    write-warning "Shutting down all VMs on $esxihost in 10 seconds"
    Start-Sleep -s 10
    Get-vmhost -Name $esxihost | Get-VM | Where {$_.name -ne $env:COMPUTERNAME} | Where PowerState -EQ PoweredOn | Shutdown-VMGuest -Confirm:$False
    
}


