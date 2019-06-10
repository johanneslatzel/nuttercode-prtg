<#
    .SYNOPSIS
        gets CA state of all components of a fujitsu eternus dx100 s3
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3CAState.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3CAState.ps1 -Hostname myHostname
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
    [Parameter(Mandatory=$True,Position=1)]
    [String]$Hostname
)


$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor
$state = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.2.3.2.1.4
$moduleId = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.2.3.2.1.5

for($a=0;$a -lt $moduleId.Length;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "CM Slot $($moduleId[$a] -band 7) Prozessor $(($moduleId[$a] -band 8) -shr 3) CA Slot $(($moduleId[$a] -band 48) -shr 4)" -value $state[$a] -value_lookup_id "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.comp-state" -unit Custom
}

$sensor | Convert-PRTGSensorToXML