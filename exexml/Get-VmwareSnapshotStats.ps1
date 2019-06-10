<#
    .SYNOPSIS
        gets current snapshot data of an vmware environment
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-VmwareSnapshotStats.ps1
    .EXAMPLE
        .\Get-VmwareSnapshotStats.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
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

$snapshots = @(get-vm | Get-Snapshot | select vm, name, sizemb, created)
$text = "$($snapshots.Count) Snapshots"
$maxSize = 0
$oldest = 0
$snapshots | % {
    if( $text.EndsWith("Snapshots") ) {
        $text += ": $($_.vm)/$($_.name)"
    }
    else {
        $text += ", $($_.vm)/$($_.name)"
    }
    $size = $_.sizemb * 1000 * 1000
    if( $size -gt $maxSize ) {
        $maxSize = $size
    }
    $age = ((Get-Date) - (Get-Date -Date $_.created)).TotalSeconds
    if( $age -gt $oldest ) {
        $oldest = $age
    }
}

New-PRTGSensor |
    Set-PRTGSensorText -text $text |
    Add-PRTGChannel -name "Snapshots" -value $snapshots.Count -unit Count |
    Add-PRTGChannel -name "Largest Snapshot" -value ([long]$maxSize) -unit BytesDisk |
    Add-PRTGChannel -name "Oldest Snapshot" -value ([long]$oldest) -unit TimeSeconds -limit (New-PRTGChannelLimit -warning_max (24 * 60 * 60) -error_max (2 * 24 * 60 * 60) -DisableMin) |
Convert-PRTGSensorToXML