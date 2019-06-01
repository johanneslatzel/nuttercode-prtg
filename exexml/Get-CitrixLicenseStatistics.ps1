########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.05.30
# 
########################################################################################################################
#
# Description:
#
#     gets the number of used licences of a citrix licensing server via WMI
#
#     based on "https://kb.paessler.com/en/topic/29223-how-can-i-set-up-a-monitor-for-citrix-license-use-on-license-server"
#
########################################################################################################################
#
# Vorausstzungen:
#
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#     SNMP module (https://github.com/johanneslatzel/powershellmodules)
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Hostname: hostname or ip address of target device
#     [string]$Username: username of authorized user (WMI read-only in "ROOT\CitrixLicensing")
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
        Add-PRTGChannel -name "$($_.pld) %" -value ([int](100 * $_.inUseCount / $_.count)) -unit Percent -limit (New-PRTGChannelLimit  -DisableMin -warning_max 90 -error_max 95)
}

$sensor | Convert-PRTGSensorToXML