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
#     gets sensor data of the fans, power supplies, memory and cpus of a 3com switch model 4200G
#
########################################################################################################################
#
# Dependencies:
#
#     Powershell 5.0
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#     SNMP module (https://github.com/johanneslatzel/powershellmodules)
#     de.nuttercode.prtg.3com.4200g.state
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


$sensor = New-PRTGSensor
$memory_total = @(Get-SNMPWalkValue -Hostname $Hostname -Oid .1.3.6.1.4.1.43.45.1.6.1.2.1.1.2)
$memory_free = @(Get-SNMPWalkValue -Hostname $Hostname -Oid .1.3.6.1.4.1.43.45.1.6.1.2.1.1.3)
$cpu = @(Get-SNMPWalkValue -Hostname $Hostname -Oid .1.3.6.1.4.1.43.45.1.6.1.1.1.3)
$fan = @(Get-SNMPWalkValue -Hostname $Hostname -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.1.1.2)
$power = @(Get-SNMPWalkValue -Hostname $Hostname -Oid .1.3.6.1.4.1.43.45.1.2.23.1.9.1.2.1.2)
for($a=0;$a -lt $memory_total.Count;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Memory Free $a" -value $memory_free[$a] -unit BytesMemory
    $sensor = $sensor | Add-PRTGChannel -name "Memory Free (%) $a" -value ([int](100 * $memory_free[$a] / $memory_total[$a])) -unit Percent -limit (New-PRTGChannelLimit -warning_min 15 -error_min 10 -DisableMax)
}
for($a=0;$a -lt $cpu.Count;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "CPU $a" -value $cpu[$a] -unit CPU -limit (New-PRTGChannelLimit -DisableMin -warning_max 85 -error_max 95)
}
for($a=0;$a -lt $fan.Count;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Fan $a Status" -value $fan[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
for($a=0;$a -lt $power.Count;$a++) {
    $sensor = $sensor | Add-PRTGChannel -name "Power $a Status" -value $power[$a] -value_lookup_id "de.nuttercode.prtg.3com.4200g.state" -unit Custom
}
$sensor | Convert-PRTGSensorToXML
