########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.06.02
# 
########################################################################################################################
#
# Description:
#
#     gets ram and cpu usage of a vmware esxi cluster
#
########################################################################################################################
#
# Vorausstzungen:
#
#     Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
#     Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
#     VMware PowerCLI 6.5
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Hostname: hostname or ip-address of vmware vcenter server
#     [string]$Username: name of authorized user
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