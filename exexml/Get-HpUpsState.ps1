<#
    .SYNOPSIS
        gets output load, output and input voltage, input frequency and current, environment temperature, and battery
        estimated time remaining, capacity, and test and advanced state of an HP UPS device
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-HpUpsState.ps1
    .EXAMPLE
        .\Get-HpUpsState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip address of remote HP UPS device
    .Parameter SnmpVersion
        snmp version "1", "2c" or "3"
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.hp.ups.battery.state" and "de.nuttercode.prtg.hp.ups.battery.advanced.state"
#>

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname,
    [Parameter(Mandatory=$False,Position=2)][String]$SnmpVersion = "2c"
)


$ErrorActionPreference = "Stop"

$sensor = New-PRTGSensor |
    Add-PRTGChannel -name "Output Load" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.4.1.0 -version $SnmpVersion) -unit Percent |
    Add-PRTGChannel -name "Input Frequency" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.3.1.0 -version $SnmpVersion) -unit Custom -custom_unit "Hz" |
    Add-PRTGChannel -name "Environment Temperature" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.6.1.0 -version $SnmpVersion) -unit Temperature -limit (New-PRTGChannelLimit -DisableMin -warning_max 40 -error_max 45) |
    Add-PRTGChannel -name "Battery Test Status" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.7.2.0 -version $SnmpVersion) -unit Custom -value_lookup_id "de.nuttercode.prtg.hp.ups.battery.state" |
    Add-PRTGChannel -name "Estimated Battery Time Remaining" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.2.1.0 -version $SnmpVersion) -unit TimeSeconds -limit (New-PRTGChannelLimit -warning_min 900 -error_min 600 -DisableMax) |
    Add-PRTGChannel -name "Battery Capacity" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.2.4.0 -version $SnmpVersion) -unit Percent -limit (New-PRTGChannelLimit -warning_min 20 -error_min 10 -DisableMax) |
    Add-PRTGChannel -name "Battery Advanced State"-value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.2.5.0 -version $SnmpVersion) -unit Custom -value_lookup_id "de.nuttercode.prtg.hp.ups.battery.advanced.state"

try {
    $sensor = $sensor | Add-PRTGChannel -name "Output Voltage" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.4.4.1.4 -version $SnmpVersion) -unit Custom -custom_unit "W"
}
catch {}
try {
    Add-PRTGChannel -name "Input Voltage" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.3.4.1.2 -version $SnmpVersion) -unit Custom -custom_unit "W"
}
catch {}
try {
    $sensor = $sensor | Add-PRTGChannel -name "Input Current" -value (Get-SNMPValue $Hostname 1.3.6.1.4.1.232.165.3.3.4.1.3 -version $SnmpVersion) -unit Custom -custom_unit "A"
}
catch {}

$sensor | Convert-PRTGSensorToXML