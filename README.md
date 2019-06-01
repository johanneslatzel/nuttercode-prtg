# nuttercode-prtg

This repository contains some scripts which  return xml data for advanced custom prtg sensors. Please refer to "https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor" and "https://www.paessler.com/manuals/prtg/custom_sensors#exe_script" for more information on PRTG advanced sensors.

All scripts are dependend on "https://github.com/johanneslatzel/powershellmodules". Please refer to the corresponding documentation and installation details before using this repositories' scripts.

Attention: Not all scripts have been tested thoroughly. Please report problems at "https://github.com/johanneslatzel/nuttercode-prtg/issues".

Available sensors for hardware:

| type | manufacturer | model | tested |
| :-: | :-: | :-: | :-: |
| switch state | 3com | 4200g | 🔴 |
| switch state | 3com | 4500g | 🔴 |
| GPU state | citrix | xen host | 🔴 |
| NIC state | vmware | ESXi | 🔴 |
| temperature sensor | HW Group | HWg-STE | 🔴 |

Available sensors for software:

| type | tested |
| :-: | :-: |
| citrix license statistics | 🔴 |
| windows dhcp statistics | 🔴 |
| windows dhcp failover state | 🔴 |
