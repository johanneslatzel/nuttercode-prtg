<#
    .SYNOPSIS
        gets all VMs of an vmware environment whose "ConsolodationState" is set
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-VmwareConsolidationNeeded.ps1
    .EXAMPLE
        .\Get-VmwareConsolidationNeeded.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
    .Parameter Hostname
        hostname or ip-address of vmware vcenter server
    .Parameter Username
        name of authorized user (read-only)
    .Parameter Password
        password of user
    .Parameter Domain
        domain of user
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
        VMware PowerCLI 6.5
#>

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