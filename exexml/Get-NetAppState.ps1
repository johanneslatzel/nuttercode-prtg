<#
    .SYNOPSIS
        gets the NVRAM und global state of a netapp device
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-NetAppState.ps1
    .EXAMPLE
        .\Get-NetAppState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of a netapp device
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.netapp.global.state" and "de.nuttercode.prtg.netapp.nvram.state"
#>

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