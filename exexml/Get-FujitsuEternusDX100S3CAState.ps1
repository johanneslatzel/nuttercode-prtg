########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.06.01
# 
########################################################################################################################
#
# Description:
#
#     gets CA state of all components of a fujitsu eternus dx100 s3
#
########################################################################################################################
#
# Dependencies:
#
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#     SNMP module (https://github.com/johanneslatzel/powershellmodules)
#     valuelookup "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.comp.state"
#
########################################################################################################################
#
# Parameter:
#
#     [String]$Hostname: hostname or ip address of remote device
#
########################################################################################################################


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
