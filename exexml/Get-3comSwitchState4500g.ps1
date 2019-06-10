<#
    .SYNOPSIS
        gets sensor data of fans, power supplies, and temperature of a 3com switch model 4500G
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-3comSwitchState4500g.ps1
    .EXAMPLE
        .\Get-3comSwitchState4500g.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of target switch
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.3com.4200g.state"
#>

Param (
    [Parameter(Mandatory=$True,Position=0)][String]$Hostname
)

$ErrorActionPreference = "Stop"
$lowerTemperatureValue = Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.5.0.1.1
$upperTemperatureValue = Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.4.0.1.1
$fan = @(Get-SNMPWalkValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.1.1.2)
$power = @(Get-SNMPWalkValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.2.1.2)
$sensor = New-PRTGSensor

for($a = 0; $a -lt $fan.Count; $a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Fan $a Status" -value $fan[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
for($a = 0; $a -lt $power.Count; $a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Power $a Status" -value $power[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
$sensor |
    Add-PRTGChannel -name "Temperature State" -value (Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.2.0.1.1) |
    Add-PRTGChannel -name "Temperature" -value (Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.3.0.1.1) -limit (
        New-PRTGChannelLimit -DisableWarningMin -error_min $lowerTemperatureValue -DisableWarningMax -error_max $upperTemperatureValue
    ) |
Convert-PRTGSensorToXML
