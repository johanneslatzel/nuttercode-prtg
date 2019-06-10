<#
    .SYNOPSIS
        gets states of all physical network interface cards of a esxi host
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-VmwareEsxiPnicState.ps1
    .EXAMPLE
        .\Get-VmwareEsxiPnicState.ps1 -VCHost myVCHost -Username myUser -Password myPassword -Domain myDomain -ESXHost myESXHost
    .Parameter VCHost
        hostname or ip-address of vmware vcenter server
    .Parameter Username
        name of authorized user (read-only)
    .Parameter Password
        password of user
    .Parameter Domain
        domain of user
    .Parameter ESXHost
        hostname of target esx host
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
        VMware PowerCLI 6.5
#>

Param (
    [Parameter(Mandatory=$True,Position=0)][string]$VCHost,
    [Parameter(Mandatory=$True,Position=1)][string]$Username,
    [Parameter(Mandatory=$True,Position=2)][string]$Password,
    [Parameter(Mandatory=$True,Position=3)][string]$Domain,
    [Parameter(Mandatory=$True, Position=4)][String]$ESXHost
)


$ErrorActionPreference = "Stop"
Import-Module VMware.VimAutomation.Core
$garbage = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User
$viServer = Connect-VIServer -Server $VCHost -User "$Domain\$Username" -Password $Password
$esxcli = Get-Esxcli -vmhost $ESXHost -V2
[String]$text = ""
$sensor = New-PRTGSensor

$esxcli.network.nic.list.invoke() | % {
    $status = 0
    # set flags if up
    if( $_.Link -eq "Up" ) {
        $status = $status -bor 1
    }
    if( $_.LinkStatus -eq "Up" ) {
        $status = $status -bor 2
    }
    if( $_.AdminStatus -eq "Up" ) {
        $status = $status -bor 4
    }
    $sensor = $sensor | Add-PRTGChannel -name "$($_.name) Status" -value $status -unit Custom -value_lookup_id "de.nuttercode.prtg.vmware.esxi.pnic.status"
}

$sensor | Convert-PRTGSensorToXML