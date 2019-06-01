########################################################################################################################
#
# Author: Johannes B. Latzel
# 
# Version: 2019.05.30
# 
########################################################################################################################
#
# Beschreibung:
#
#     calls "nvidia-smi" (via ssh) on the target device (citrix xen host) and parses the resulting data corresponding
#     to the physical gpus
#
########################################################################################################################
#
# Dependencies:
#
#     Posh-SSH module (https://www.powershellgallery.com/packages/Posh-SSH/2.1)
#
########################################################################################################################
#
# Parameter:
#
#     [string]$Hostname: hostname or ip address of remote device
#     [string]$Username: username of user authorized to access the target device via ssh
#     [string]$Password: password of user
#
########################################################################################################################

Param(
    [Parameter(Mandatory=$True,Position=0)][string]$Hostname,
    [Parameter(Mandatory=$True,Position=1)][string]$Username,
    [Parameter(Mandatory=$True,Position=2)][string]$Password
)


$ErrorActionPreference = "Stop"

$session = New-SSHSession -AcceptKey -ComputerName $Hostname -Credential (
    New-Object System.Management.Automation.PSCredential("$Username", ($Password | ConvertTo-SecureString -AsPlainText -Force))
)
$result = Invoke-SSHCommand -Command "nvidia-smi" -SSHSession $session
$text = $result.Output
$sensor = New-PRTGSensor

$line = 7
while( $text[$line].Replace(" ", "").Length -gt 0) {
    $values = @($text[$line++].Replace("|", "").Split(" ", [StringSplitOptions]::RemoveEmptyEntries))
    $values += @($text[$line++].Replace("|", "").Split(" ", [StringSplitOptions]::RemoveEmptyEntries))
    $line++
    $gpuIndex = [int]$values[0]
    $temperature = [int]$values[8].Replace("C", "")
    $powerUsage = [int]$values[10].Replace("W", "")
    $powerTotal = $values[12].Replace("W", "")
    $memoryUsage = [int]$values[13].Replace("MiB", "")
    $memoryTotal = $values[15].Replace("MiB", "")
    $gpuUsage = [int]$values[16].Replace("%", "")
    $sensor = $sensor |
        Add-PRTGChannel -name "GPU $($values[0]) Temperature" -value $temperature -unit Temperature -limit (New-PRTGChannelLimit -DisableMin -warning_max 35 -error_max 40) |
        Add-PRTGChannel -name "GPU $($values[0]) Power Usage" -value ([int]($powerUsage * 100 / $powerTotal)) -unit Percent -limit (New-PRTGChannelLimit -DisableMin -warning_max 85 -error_max 95) |
        Add-PRTGChannel -name "GPU $($values[0]) Memory Usage" -value ([int]($memoryUsage * 100 / $memoryTotal)) -unit Percent -limit (New-PRTGChannelLimit -DisableMin -warning_max 85 -error_max 95) |
        Add-PRTGChannel -name "GPU $($values[0]) Usage" -value $gpuUsage -unit Percent -limit (New-PRTGChannelLimit -DisableMin -warning_max 85 -error_max 95)
}

$sensor | Convert-PRTGSensorToXML