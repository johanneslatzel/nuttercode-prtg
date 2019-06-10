<#
    .SYNOPSIS
        gets ram and cpu usage of a vmware esxi cluster
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-VmwareClusterStats.ps1
    .EXAMPLE
        .\Get-VmwareClusterStats.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
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

$ramTotal = 0
$ramUsage = 0
$cpuTotal = 0
$cpuUsage = 0

Get-VMHost | % {
    $ramTotal += $_.MemoryTotalGB
    $ramUsage += $_.MemoryUsageGB
    $cpuTotal += $_.CpuTotalMhz
    $cpuUsage += $_.CpuUsageMhz
}

New-PRTGSensor |
    Add-PRTGChannel -name "Ram Usage" -value ([long]($ramUsage * 1024 * 1024 * 1024)) -unit BytesMemory |
    Add-PRTGChannel -name "Ram Usage %" -value ([long]($ramUsage * 100 / $ramTotal)) -unit Percent -limit (New-PRTGChannelLimit -warning_max 40 -error_max 45 -DisableMin) |
    Add-PRTGChannel -name "CPU Usage" -value ([long]$cpuUsage) -unit Custom -custom_unit "MHz" |
    Add-PRTGChannel -name "CPU Usage %" -value ([long]($cpuUsage * 100 / $cpuTotal)) -unit Percent -limit (New-PRTGChannelLimit -warning_max 40 -error_max 45 -DisableMin) |
Convert-PRTGSensorToXML