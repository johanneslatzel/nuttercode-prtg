<#
    .SYNOPSIS
        gets temperature of device and controller enclosures (max of last hour in °C) of a fujitsu eternus dx100 s3
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3Temperature.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3Temperature.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of target eternus node
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
#>

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)


$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor
$cmNumber = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.13.3.2.1.3
$cmTemperature = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.13.3.2.1.5
$enclosureIndex = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.13.4.2.1.1
$enclosureType = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.13.4.2.1.6
$enclosureTemperature = Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.211.1.21.1.150.13.4.2.1.7

for($a=0;$a -lt $cmNumber.Length;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "CM $($cmNumber[$a]) Temperature" -value $cmTemperature[$a] -unit Temperature -limit (New-PRTGChannelLimit -DisableMin -warning_max 25 -error_max 30)
}
for($a=0;$a -lt $enclosureIndex.Length;$a++) {
    if ($enclosureTemperature[$a] -eq "-128") {
        continue
    }
    $sensor = $sensor | Add-PRTGChannel -name (
    $(
        switch ($enclosureType[$a]) {
            "16" {"CE"}
            "32" {"DE"}
            default {"unknown"}
        }
    ) + " $($enclosureIndex[$a]) Temperature") -value $enclosureTemperature[$a] -unit Temperature -limit (New-PRTGChannelLimit -DisableMin -warning_max 25 -error_max 30)
}

$sensor | Convert-PRTGSensorToXML