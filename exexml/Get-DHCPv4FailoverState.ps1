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
#     gets failover state of a windows server dhcp cluster
#
########################################################################################################################
#
# Dependencies:
#
#     value lookup "de.nuttercode.prtg.windows.server.dhcp.failover.state"
#     target device: Windows DHCP-Server with "Get-DhcpServerv4Failover" CMDlet installed
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
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
$sensor | Set-PRTGSensorText -text $(
    Invoke-Command -ScriptBlock {
        Get-DhcpServerv4ScopeStatistics | % {
            Get-DhcpServerv4Failover -ScopeId $_.ScopeID
        }
    } -ComputerName $Hostname -Credential (New-Object System.Management.Automation.PSCredential("$Domain\$Username", ($Password | ConvertTo-SecureString -AsPlainText -Force))) |
    % {$text=""} {
        $sensor = $sensor | Add-PRTGChannel -name $_.ScopeID -value $_.State.GetHashCode() -unit Custom -value_lookup_id "de.nuttercode.prtg.windows.server.dhcp.failover.state"
        $text += " " + $_.ScopeID + ": " + $_.State
    } {$text.Trim()}
) | Convert-PRTGSensorToXML