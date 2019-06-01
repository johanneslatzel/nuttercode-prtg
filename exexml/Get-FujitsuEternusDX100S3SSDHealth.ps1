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
#     gets health state of all ssds of a fujitsu eternus dx100 s3 in percent
#
########################################################################################################################
#
# Dependencies:
#
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#     SNMP module (https://github.com/johanneslatzel/powershellmodules)
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

$numberOfDisks = Get-SNMPValue $Hostname .1.3.6.1.4.1.211.1.21.1.150.2.19.1.0

for($a=0;($a -lt $numberOfDisks) -and ($a -lt $Disks);$a++) {
    $status = Get-SNMPValue $Hostname .1.3.6.1.4.1.211.1.21.1.150.2.19.2.1.4.$a
    if( $status -eq 68) {
        continue
    }
    $ssdHealth = Get-SNMPValue $Hostname .1.3.6.1.4.1.211.1.21.1.150.2.19.2.1.17.$a
    if( $ssdHealth -ne "-1" ) {
        $sensor = $sensor | Add-PRTGChannel -name "Disk $a" -value $ssdHealth -unit Percent -Limit (New-PRTGChannelLimit -DisableMax -warning_min 50 -error_min 25)
    }
}

$sensor | Convert-PRTGSensorToXML
