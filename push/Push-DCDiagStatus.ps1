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
#     runs dcdiag on the local domain controller, parses the output and sends the results to a prtg server via http push
#
########################################################################################################################
#
# Dependencies:
#
#     PRTG module (https://github.com/johanneslatzel/powershellmodules)
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Probename: hostname of ip address of remote probe on which a http push sensor is configured
#     [string]$Port: port of the http push sensor
#     [string]$Guid: giud of the http push sensor
#
########################################################################################################################


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