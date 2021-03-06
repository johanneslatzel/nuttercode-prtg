﻿<#
    .SYNOPSIS
        gets state of all raid groups of a fujitsu eternus dx100 s3
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3RAIDState.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3RAIDState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of target eternus node
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.fujitsu.eternus.dx100s3.raid.state"
#>

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)


$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor
$groupNumber = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.14.3.2.1.1
$state = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.14.3.2.1.2

for($a=0;$a -lt $groupNumber.Length;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "RAID Group $($groupNumber[$a])" -value $state[$a] -value_lookup_id "de.nuttercode.prtg.fujitsu.eternus.dx100s3.raid.state" -unit Custom
}

$sensor | Convert-PRTGSensorToXML