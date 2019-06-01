# nuttercode-prtg

This repository contains some scripts which return xml data for [advanced custom sensors](https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor) as an [exe/xml sensor](https://www.paessler.com/manuals/prtg/custom_sensors#exe_script) for [prtg monitoring](https://www.de.paessler.com/prtg).

All scripts are dependend on [those PRTG and SNMP powershell modules](https://github.com/johanneslatzel/powershellmodules). Additional dependencies are documented in the dependend scripts.

Available sensors:

| type | manufacturer | model | tested |
| :-: | :-: | :-: | :-: |
| switch state | 3com | 4200g | 🔴 |
| switch state | 3com | 4500g | 🔴 |
| GPU state | citrix | xen host | 🔴 |
| NIC state | vmware | ESXi | 🔴 |
| environment temperature | HW Group | HWg-STE | 🔴 |
| license statistics | citrix | | 🔴 |
| windows dhcp statistics and failover state | | | 🔴 |
| ssd health, temperature, and ca, cm, disk, raid, and volume state | fujitsu | eternus dx100 s3 | 🔴 |

Feel free to [contribute](https://github.com/johanneslatzel/nuttercode-prtg/blob/master/CONTRIBUTING.md).
