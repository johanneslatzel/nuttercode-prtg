<#
    .SYNOPSIS
        gets state of all disks and (if ssd) their health of a fujitsu eternus dx100 s3
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3DiskState.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3DiskState.ps1 -Hostname myHostname
    .Parameter Hostname
        hostname or ip-address of target eternus node
    .Parameter Disks
        number of disks (to prevent display of all 1200 possible disks)
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nuttercode.prtg.fujitsu.eternus.dx100s3.disk.state"
#>

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