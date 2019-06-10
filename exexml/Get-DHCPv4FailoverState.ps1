<#
    .SYNOPSIS
        gets failover state of a windows server dhcp cluster
    .DESCRIPTION
        see synopsis.
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-DHCPv4FailoverState.ps1
    .EXAMPLE
        .\Get-DHCPv4FailoverState.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
    .Parameter Hostname
        hostname or ip-address of windows server (DHCP-server with "Get-DhcpServerv4Failover" CMDlet installed)
    .Parameter Username
        username of authorized user (WMI)
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
        valuelookup "de.nuttercode.prtg.windows.server.dhcp.failover.state"
#>

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