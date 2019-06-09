########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.06.09
# 
########################################################################################################################
#
# Description:
#
#     gets the NVRAM und global state of a netapp device
#
########################################################################################################################
#
# Dependecies:
#
#     Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
#     Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
#     valuelookup "de.nuttercode.prtg.netapp.global.state" and "de.nuttercode.prtg.netapp.nvram.state"
#
########################################################################################################################
#
# Parameter:
#
#     [String]$Hostname: hostname or ip-address of a netapp device
#
########################################################################################################################


Param (
    [Parameter(Mandatory=$True,Position=1)][String]$Hostname
)


$ErrorActionPreference = "Stop"

$gloablStateMessage = Get-SNMPValue -Hostname $Hostname -Oid ".1.3.6.1.4.1.789.1.2.2.25.0"
$model = Get-SNMPValue -Hostname $Hostname -Oid ".1.3.6.1.4.1.789.1.1.5.0"
$obtapVersion = Get-SNMPValue -Hostname $Hostname -Oid ".1.3.6.1.4.1.789.1.1.2.0"

New-PRTGSensor |
    Add-PRTGChannel -name "Global State" -value (Get-SNMPValue -Hostname $Hostname -Oid ".1.3.6.1.4.1.789.1.2.2.4.0") -unit Custom -value_lookup_id "de.nuttercode.prtg.netapp.global.state" |
    Add-PRTGChannel -name "NVRAM State" -value (Get-SNMPValue -Hostname $Hostname -Oid ".1.3.6.1.4.1.789.1.2.5.1.0") -unit Custom -value_lookup_id "de.nuttercode.prtg.netapp.nvram.state" |
    Set-PRTGSensorText -text ($model.Replace("`"", "").Trim() + " - " + $obtapVersion.Replace("`"", "").Trim() + " - " + $gloablStateMessage.Replace("`"", "").Trim()) |
Convert-PRTGSensorToXML
