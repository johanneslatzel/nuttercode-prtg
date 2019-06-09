# nuttercode-prtg

This repository contains some scripts which return xml data for [advanced custom sensors](https://www.paessler.com/manuals/prtg/exe_script_advanced_sensor) as an [exe/xml sensor](https://www.paessler.com/manuals/prtg/custom_sensors#exe_script) for [prtg monitoring](https://www.de.paessler.com/prtg).

All scripts are dependend on [those PRTG and SNMP powershell modules](https://github.com/johanneslatzel/powershellmodules). Additional dependencies are documented in the dependend scripts. A full documentation will be added in the future.

Available sensors:

| data | manufacturer | model/type | tested |
| :-: | :-: | :-: | :-: |
| switch state | 3com | switch 4200g and 4500g | 🔴 |
| gpu state | citrix | xen host | 🔴 |
| environment temperature | hw group | hwg-ste | 🔴 |
| license statistics | citrix | windows server | 🔴 |
| windows dhcp statistics and failover state | microsoft | windows server (dhcp) | 🔴 |
| ssd health, temperature, and ca, cm, disk, raid, and volume state | fujitsu | eternus dx100 s3 | 🔴 |
| snapshot statistics and consolidation needed, esxi pnic state, and cluster usage | vmware | vcenter/esxi | 🔴 |
| nvram and global state | netapp | ontap storage node/cluster | 🔴 |
| output load, output and input voltage, input frequency and current, environment temperature, and battery estimated time remaining, capacity, and test and advanced state | hp | ups | 🔴 |

Feel free to [contribute](https://github.com/johanneslatzel/nuttercode-prtg/blob/master/CONTRIBUTING.md).
