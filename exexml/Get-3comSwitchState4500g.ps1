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
#     gets sensor data of the fans, power supplies, and temperature of a 3com switch model 4500G
#
########################################################################################################################
#
# Dependencies:
#
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#     SNMP module (https://github.com/johanneslatzel/powershellmodules)
#     valuelookup "de.nuttercode.prtg.3com.4200g.state"
#
########################################################################################################################
#
# Parameter:
#
#     [String]$Hostname: hostname or ip-address of target
#
########################################################################################################################

Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)
$ErrorActionPreference = "Stop"


$lowerTemperatureValue = Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.5.0.1.1
$upperTemperatureValue = Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.4.0.1.1

$sensor = New-PRTGSensor |
    Add-PRTGChannel -name "Temperature State" -value (Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.2.0.1.1) |
    Add-PRTGChannel -name "Temperature" -value (Get-SNMPValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.3.1.3.0.1.1) -limit (
        New-PRTGChannelLimit -DisableWarningMin -error_min $lowerTemperatureValue -DisableWarningMax -error_max $upperTemperatureValue
    )
$fan = @(Get-SNMPWalkValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.1.1.2)
$power = @(Get-SNMPWalkValue -Hostname $ip -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.2.1.2)
for($a = 0; $a -lt $fan.Count; $a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Fan $a Status" -value $fan[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
for($a = 0; $a -lt $power.Count; $a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Power $a Status" -value $power[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
$sensor | Convert-PRTGSensorToXML
