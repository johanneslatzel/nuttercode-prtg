########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.06.01
#
########################################################################################################################
#
# Description:
#
#     gets DHCP-Scope usage of a windows dhcp server (cluster)
#
########################################################################################################################
#
# Dependencies:
#
#     target device: Windows DHCP-Server with "Get-DhcpServerv4ScopeStatistics" CMDlet installed
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Hostname: hostname or ip-address of dhcp server
#     [string]$Username: name of authorized user (WMI)
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

$sensor = New-PRTGSensor
Invoke-Command -ScriptBlock {Get-DhcpServerv4ScopeStatistics} -ComputerName $Hostname -Credential (
    New-Object System.Management.Automation.PSCredential("$Domain\$Username", ($Password | ConvertTo-SecureString -AsPlainText -Force))
) | % {
    $sensor = $sensor |
    Add-PRTGChannel -name "$($_.ScopeID) in use (%)" -value ([int]$_.PercentageInUse) -unit Percent -limit (New-PRTGChannelLimit -DisableMin -warning_max 93 -error_max 97) |
    Add-PRTGChannel -name "$($_.ScopeID) free" -value ([int]$_.Free) |
    Add-PRTGChannel -name "$($_.ScopeID) in use" -value ([int]$_.InUse) |
    Add-PRTGChannel -name "$($_.ScopeID) reserved" -value ([int]$_.Reserved)
}
$sensor | Convert-PRTGSensorToXML