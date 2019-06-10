<#
    .SYNOPSIS
        runs dcdiag on the local domain controller, parses the output and sends the results to a prtg server via http push
    .DESCRIPTION
        see synopsis. default port is 5050 and default guid is the local computername (lower case).
    .NOTES
        Author: Johannes B. Latzel (http://www.nuttercode.de)
    .LINK
       https://github.com/johanneslatzel/nuttercode-prtg/wiki/Push-DCDiagStatus.ps1
    .EXAMPLE
        .\Push-DCDiagStatus -Probename myProbename
    .EXAMPLE
        .\Push-DCDiagStatus -Probename myProbename -Port myPort -Guid myGuid
    .Parameter Probename
        hostname of ip address of remote probe on which a http push sensor is configured
    .Parameter Port
        port of the http push sensor
    .Parameter Guid
        guid of the http push sensor
    .INPUTS
        parameter
    .OUTPUTS
        exexml format of sensor output
    .COMPONENT
        Nuttercode-PRTG (https://github.com/johanneslatzel/powershellmodules)
#>

Param (
    [Parameter(Mandatory=$True,Position=0)][string]$Probename,
    [Parameter(Mandatory=$False,Position=1)][string]$Port = 5050,
    [Parameter(Mandatory=$False,Position=2)][string]$Guid = $env:COMPUTERNAME.ToLower()
)


$ErrorActionPreference = "Stop"
$sensor = New-PRTGSensor

@(
    "replications"
    "services"
    "advertising"
    "fsmocheck"
    "ridmanager"
    "machineaccount"
) | % {
    $state = 1
    $test = $_
    if( "$(dcdiag /q /test:$test)" -ne "") {
        $state = 0
    }
    $sensor = $sensor | Add-PRTGChannel -name $test -value $state -unit Custom -value_lookup_id "de.nuttercode.prtg.windows.server.dcdiag"
}

$response = Invoke-WebRequest -Uri "http://$($Probename):$Port/$($Guid)?content=$([uri]::EscapeDataString($($sensor | Convert-PRTGSensorToXML)))" -Method Get