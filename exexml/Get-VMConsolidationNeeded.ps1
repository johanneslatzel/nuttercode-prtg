########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.06.09
# 
########################################################################################################################
#
# Description:
#
#     gets all VMs of an vmware environment whose "ConsolodationState" is set
#
########################################################################################################################
#
# Dependencies:
#
#     target device is vmware vcenter server
#     PowerCLI 6.5
#     Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Hostname: hostname or ip-address of vmware vcenter server
#     [string]$Username: name of authorized user (read-only)
#     [string]$Password: password of user
#     [string]$Domain: domain of user
#
########################################################################################################################


Param (
    [Parameter(Mandatory=$True,Position=0)][string]$Hostname,
    [Parameter(Mandatory=$True,Position=1)][string]$Username,
    [Parameter(Mandatory=$True,Position=2)][string]$Password,
    [Parameter(Mandatory=$True,Position=3)][string]$Domain
)


$ErrorActionPreference = "Stop"
Import-Module VMware.VimAutomation.Core
$garbage = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User
$viServer = Connect-VIServer -Server $Hostname -User "$Domain\$Username" -Password $Password

[string[]]$consolidationNeededVMs = Get-VM | ? { $_.ExtensionData.Runtime.ConsolidationNeeded } | % { $_.Name }
[string]$text = ""
if( $count -gt 0 ) {
    $text = "$($consolidationNeededVMs.Count) VMs:" + ($consolidationNeededVMs | % {[string]$a=""} {$a += " " + $_} {$a.Trim()})
}

New-PRTGSensor | 
    Set-PRTGSensorText -text $text |
    Add-PRTGChannel -name "Count" -value $consolidationNeededVMs.Count -unit Count -limit (New-PRTGChannelLimit -DisableMin -warning_max 0.5 -error_max 1.5) |
Convert-PRTGSensorToXML