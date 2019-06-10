<#
    .SYNOPSIS
        gets teh state and temperature of a HWg-STE temperature device (https://www.hw-group.com/device/hwg-ste)
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-HwgSteState.ps1
    .EXAMPLE
        .\Get-HwgSteState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip address of the remote device
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.hwg-ste.temperature-sensor.state"
#>

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)

$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor

Get-SNMPWalkValue $Hostname 1.3.6.1.4.1.21796.4.1.3.1.1 | % {
    $state = Get-SNMPValue $Hostname "1.3.6.1.4.1.21796.4.1.3.1.3.$_"
    if ( ($state -eq 0) -or ($state -eq $null) ) {
        return
    }
    $name = Get-SNMPValue $Hostname "1.3.6.1.4.1.21796.4.1.3.1.2.$_"
    $temperature = ([int](Get-SNMPValue $Hostname ("1.3.6.1.4.1.21796.4.1.3.1.5." + $_))) / 10
    $sensor = $sensor |
        Add-PRTGChannel -name "$name State" -value $state -value_lookup_id "de.nuttercode.prtg.hwg-ste.temperature-sensor.state" -unit Custom |
        Add-PRTGChannel -name "$name Temperature" -value $temperature -unit Temperature -is_float -limit (New-PRTGChannelLimit -DisableMin -warning_max 28 -error_max 32)
}

$sensor | Convert-PRTGSensorToXML