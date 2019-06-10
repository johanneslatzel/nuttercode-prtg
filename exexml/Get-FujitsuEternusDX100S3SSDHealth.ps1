<#
    .SYNOPSIS
        gets health state of all ssds of a fujitsu eternus dx100 s3 in percent
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-FujitsuEternusDX100S3SSDHealth.ps1
    .EXAMPLE
        .\Get-FujitsuEternusDX100S3SSDHealth.ps1 -Hostname myHostname -Disks 10
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
#>

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