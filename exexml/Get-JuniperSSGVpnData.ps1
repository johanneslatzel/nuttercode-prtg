<#
    .SYNOPSIS
        gets state and input/output bytes of a phase two vpn connection of a juniper ssg firewall
    .DESCRIPTION
        see synopsis
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Get-JuniperSSGVpnData.ps1
    .EXAMPLE
        .\Get-JuniperSSGVpnData.ps1 -FirewallHostname myFirewallHostname - VpnName myVpn
    .EXAMPLE
        .\Get-JuniperSSGVpnData.ps1 -FirewallHostname myFirewallHostname - VpnName myVpn -OptionalSnmpIndex 42
    .Parameter FirewallHostname
        hostname or ip address of juniper ssg firewall
    .Parameter VpnName
        name of an phase two vpn connection
    .Parameter OptionalSnmpIndex
        reduces time to find snmp table entry
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG and Nuttercode-SNMP (https://github.com/johanneslatzel/powershellmodules)
        valuelookup "de.nutttercode.prtg.juniper.ssg.vpn.ph2.state"
#>

Param(
    [Parameter(Position=0, Mandatory=$true)][string]$FirewallHostname,
    [Parameter(Position=1, Mandatory=$true)][string]$VpnName,
    [Parameter(Position=2, Mandatory=$false)][int]$OptionalSnmpIndex = -1
)

$ErrorActionPreference = "Stop"
[int]$index = -1

Get-SNMPWalk -Hostname $FirewallHostname -Oid "1.3.6.1.4.1.3224.4.1.1.1.4" | % {
    if( ($index -eq -1) -and ($_.Value.Replace("`"", "").Trim() -eq $VpnName) ) {
        $current_index = $_.Oid.Split(".")[-1]
        if( ($OptionalSnmpIndex -eq -1) -or ($OptionalSnmpIndex -eq $current_index) ) {
            $index = $current_index
        }
    }
}

if( $index -ne -1 ) {
    $ph2State = Get-SNMPValue -Hostname $FirewallHostname -Oid "1.3.6.1.4.1.3224.4.1.1.1.23.$index"
    $bytesIn = Get-SNMPValue -Hostname $FirewallHostname -Oid "1.3.6.1.4.1.3224.4.1.1.1.35.$index"
    $bytesOut = Get-SNMPValue -Hostname $FirewallHostname -Oid "1.3.6.1.4.1.3224.4.1.1.1.36.$index"
    New-PRTGSensor | Add-PRTGChannel -name "Ph2 State" -value $ph2State -unit Custom -value_lookup_id "de.nutttercode.prtg.juniper.ssg.vpn.ph2.state" |
    Add-PRTGChannel -name "Bytes In" -value $bytesIn -unit BytesBandwidth -mode Difference |
    Add-PRTGChannel -name "Bytes Out" -value $bytesOut -unit BytesBandwidth -mode Difference |
    Convert-PRTGSensorToXML
}
else {
    $sensor = New-PRTGSensor
    $sensor.setError(1, "No vpn cpnnectioon $VpnName with optional index $OptionalSnmpIndex available.")
    $sensor | Convert-PRTGSensorToXML
}

