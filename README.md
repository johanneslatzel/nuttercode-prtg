# nuttercode-prtg

This repository contains some scripts which return xml data for [advanced custom sensors](https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor) as an [exe/xml sensor](https://www.paessler.com/manuals/prtg/custom_sensors#exe_script) for [prtg monitoring](https://www.de.paessler.com/prtg).

All scripts are dependend on [those PRTG and SNMP powershell modules](https://github.com/johanneslatzel/powershellmodules). Additional dependencies are documented in the dependend scripts. A full documentation will be added in the future.

Available sensors:

| type | manufacturer | model | tested |
| :-: | :-: | :-: | :-: |
| switch state | 3com | 4200g | 🔴 |
| switch state | 3com | 4500g | 🔴 |
| gpu state | citrix | xen host | 🔴 |
| environment temperature | hw group | hwg-ste | 🔴 |
| license statistics | citrix | | 🔴 |
| windows dhcp statistics and failover state | | | 🔴 |
| ssd health, temperature, and ca, cm, disk, raid, and volume state | fujitsu | eternus dx100 s3 | 🔴 |
| snapshot statistics and consolidation needed, esxi pnic state, and cluster usage | vmware/esxi |  | 🔴 |
| nvram and global state | netapp |  | 🔴 |
| output load, output and input voltage, input frequency and current, environment temperature, and battery estimated time remaining, capacity, and test and advanced state | hp ups |  | 🔴 |

Feel free to [contribute](https://github.com/johanneslatzel/nuttercode-prtg/blob/master/CONTRIBUTING.md).
