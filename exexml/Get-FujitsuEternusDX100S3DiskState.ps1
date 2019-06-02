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
#     gets state of all disks and (if ssd) their health of a fujitsu eternus dx100 s3
#
########################################################################################################################
#
# Dependencies:
#
#     Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
#     Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
#     valuelookup "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.state"
#
########################################################################################################################
#
# Parameter:
#
#     [String]$Hostname: hostname or ip address of remote device
#     [int]$Disks: number of disks (to prevent display of all 1200 possible disks)
#
########################################################################################################################


Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname,
    [Parameter(Mandatory=$True,Position=2)][int]$Disks
)


$ErrorActionPreference = "Stop"


$sensor = New-PRTGSensor
$spareDisks = 0
$numberOfDisks = Get-SNMPValue $Hostname .1.3.6.1.4.1.211.1.21.1.150.2.19.1.0

for($a=0;($a -lt $numberOfDisks) -and ($a -lt $Disks);$a++) {
    $state = Get-SNMPValue $Hostname .1.3.6.1.4.1.211.1.21.1.150.2.19.2.1.4.$a
    if( $state -eq 68) {
        continue
    }
    if( $state -eq 65) {
        $spareDisks++
    }
    $sensor = $sensor | Add-PRTGChannel -name "Disk $a" -value $state -value_lookup_id "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.state" -unit Custom
}

$sensor | Add-PRTGChannel -name "Spare Disks" -value $spareDisks -limit (New-PRTGChannelLimit -DisableWarningMin -DisableMax -error_min 1) | Convert-PRTGSensorToXML
