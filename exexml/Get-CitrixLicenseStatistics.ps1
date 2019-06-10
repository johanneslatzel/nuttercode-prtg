<#
    .SYNOPSIS
        gets the number of used licences on a citrix licensing server via WMI
    .DESCRIPTION
        see synopsis. based on "https://kb.paessler.com/en/topic/29223-how-can-i-set-up-a-monitor-for-citrix-license-use-on-license-server".
        every type of licenses is represented in two channels (absolute and percentage).
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-CitrixLicenseStatistics.ps1
    .EXAMPLE
        .\Get-CitrixLicenseStatistics.ps1 -Hostname myHostname -Username myUser -Password myPassword -Domain myDomain
    .Parameter Hostname
        hostname or ip-address of windows server
    .Parameter Username
        username of authorized user (WMI read-only in "ROOT\CitrixLicensing")
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
        WMI "ROOT\CitrixLicensing"
#>

Param (
    [Parameter(Mandatory=$True,Position=0)][string]$Hostname,
    [Parameter(Mandatory=$True,Position=1)][string]$Username,
    [Parameter(Mandatory=$True,Position=2)][string]$Password,
    [Parameter(Mandatory=$True,Position=3)][string]$Domain
)

class NMBCitrixLicenseStat {
    [string]$pld
    [int]$count
    [int]$inUseCount
}


$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor

Get-WmiObject -Class "Citrix_GT_License_Pool" -Namespace "ROOT\CitrixLicensing" -ComputerName $Hostname -Credential (New-Object System.Management.Automation.PSCredential("$Domain\$Username", ($Password | ConvertTo-SecureString -AsPlainText -Force))) | select PLD, Count, InUseCount | % {$list = New-Object -TypeName System.Collections.ArrayList} {
    $found = $false
    $currentObject = $_
    $list | % {
        if($_.pld -eq $currentObject.PLD) {
            $found = $true
            $_.count += $currentObject.Count
            $_.inUseCount += $currentObject.InUseCount
            return
        }
    }
    if(-not $found) {
        $stat = [NMBCitrixLicenseStat]::new()
        $stat.pld = $currentObject.PLD
        $stat.count = $currentObject.Count
        $stat.inUseCount = $currentObject.InUseCount
        $garbage = $list.Add($stat)
    }
} {$list} | % {
    $sensor = $sensor |
        Add-PRTGChannel -name "$($_.pld)" -value $_.inUseCount -unit Count |
        Add-PRTGChannel -name "$($_.pld) %" -value ([int](100 * $_.inUseCount / $_.count)) -unit Percent -limit (New-PRTGChannelLimit -DisableMin -warning_max 90 -error_max 95)
}

$sensor | Convert-PRTGSensorToXML