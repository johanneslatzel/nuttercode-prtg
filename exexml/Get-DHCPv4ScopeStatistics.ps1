<#
    .SYNOPSIS
        gets DHCP-Scope usage of a windows dhcp server (cluster)
    .DESCRIPTION
        see synopsis.
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-DHCPv4ScopeStatistics.ps1
    .EXAMPLE
        .\Get-DHCPv4ScopeStatistics.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
    .Parameter Hostname
        hostname or ip-address of windows server (DHCP-server with "Get-DhcpServerv4ScopeStatistics" CMDlet installed)
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