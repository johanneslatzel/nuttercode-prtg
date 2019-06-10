<#
    .SYNOPSIS
        gets cm state of a fujitsu eternus dx100 s3
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3CMState.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3CMState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of target eternus node
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.comp.state"
#>

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)

$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor
$status = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.2.1.2.1.4
$moduleId = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.2.1.2.1.5

for($a=0;$a -lt $moduleId.Length;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name ("CM Slot $($moduleId[$a] -band 7)") -value $status[$a] -value_lookup_id "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.comp.state" -unit Custom
}

$sensor | Convert-PRTGSensorToXML