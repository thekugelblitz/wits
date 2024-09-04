
---

# wits v2 (What Is This Server?)

Why this thing exists? As a sysadmin, there are times when we receive a new server from a data centre or ship a server for colocation. Once the server is prepared, we want to check if everything is as expected in terms of specifications. Going through packages and software to get hardware details is fun, but it can be time-consuming and sometimes painful. That's why I created this shell script!

**wits v2** is a comprehensive Bash script designed to gather detailed hardware and system information from Linux servers. It provides essential insights into the server's CPU, RAM, storage, RAID configuration, network interfaces, public IP addresses, operating system details, and more. This script is particularly useful for system administrators and IT professionals who need a quick overview of the server's specifications and health status.

## Super Features: Package Manager Compatibility

Different Linux distributions use different package managers. For example:

- **Debian-based (Ubuntu, Debian):** `apt-get`
- **Red Hat-based (CentOS, RHEL, Fedora):** `yum` or `dnf`
- **SUSE-based (openSUSE, SLES):** `zypper`

To make script more versatile, I considered adding checks for the available package manager and adjust the package installation commands accordingly. This will allow the script to run on a wider range of Linux distributions without manual modifications.

## Command Compatibility

Ensure all commands used in the script (like `dmidecode`, `lshw`, `smartctl`, etc.) are installed or available across different distributions. Some commands may have different names or might not be installed by default. To address this:

- Include checks in your script to verify the presence of required commands.
- Provide instructions for installing these commands if they are missing.
- Consider adding conditional logic to handle different command names or paths that might vary by distribution.


## Detailed Features

- **CPU Information**: Displays details about CPU threads, cores, sockets, model name, and clock speeds.
- **RAM Information**: Provides information about installed memory, including size, type, speed, manufacturer, and voltage.
- **Storage Drives Information**: Lists all storage drives and their configurations.
- **RAID Information**: Checks for RAID configurations and details.
- **Network Card Information**: Retrieves information about installed network interfaces.
- **Public IP Addresses**: Displays the server's public IP addresses.
- **OS and Kernel Information**: Shows details about the operating system and kernel version.
- **Disk Health Status**: Performs a SMART health check on all disks.
- **Power Supply and Motherboard Information**: Displays information about the motherboard and power supply.
- **Network Configuration**: Provides details about the default gateway and DNS servers.
- **Routing Table**: Shows the current kernel IP routing table.
- **Automatic Package Management**: Checks for necessary packages and installs them if missing.

## Requirements: Linux Distro :)

The script will automatically check for these packages and prompt the user to install any missing ones on the user's behalf. (As I said, it's painless)

- `redhat-lsb-core`
- `smartmontools`
- `dmidecode`
- `lshw`


## Usage & Guidelines:

- It is highly recommended to run this on a new/fresh server rather than a server running in production. I created and tested the script on the cPanel/WHM server based on CloudLinux OS 8 with active test websites running in the background. Though I recommend running it a little carefully.
- This script uses lots of small commands via many packages, overtime these all will start to stop running effectively. So consider updating the script manually or using AI like ChatGPT. I created v1 back in the college in 2018. Version 2 was needed for the same reason, I used copilot and some part of ChatGPT 4o to make it awesome again! 

### Clone the Repository to RUN!

To get started, clone the repository to your local machine:

```bash
wget https://raw.githubusercontent.com/thekugelblitz/wits/main/witsV2.sh
chmod +x witsV2.sh
./witsV2.sh
```

### Script Output

The script outputs detailed system information to the console and also logs the information in two files:

1. **Summary File**: `server_info_<timestamp>.txt` - Contains a summary of the server's hardware and system information.
2. **Raw Log File**: `wits_execution_<timestamp>-raw-output.log` - Contains raw command outputs for detailed logs and troubleshooting.

The `<timestamp>` is generated based on the date and time when the script is run, ensuring unique filenames for each execution.

### Removing Installed Packages

At the end of the script execution, you will be prompted whether to remove the packages installed by the script. This helps keep your system clean if those packages are not needed anymore:

```bash
Would you like to remove the installed packages? (Y/N): n
```

Type `Y` to remove or `N` to keep the packages.


Here’s the full output of the script with masked serial numbers to include in your README:

---

## Example Output

Below is a full example output of the `wits v2` script. The serial numbers have been masked for privacy.

```plaintext
CPU Information
------------------------------------
Thread(s) per core:  2
Core(s) per socket:  16
Socket(s):           1
Model name:          AMD EPYC 7282 16-Core Processor
BIOS Model name:     AMD EPYC 7282 16-Core Processor
CPU MHz:             3195.016
CPU max MHz:         2800.0000
CPU min MHz:         1500.0000

RAM Information
------------------------------------
Size: 64 GB
Locator: DIMM_P0_A1
Bank Locator: BANK
Type: DDR4
Speed: 3200 MT/s
Manufacturer: Micron Technology
Serial Number: XXX
Part Number: 36ASF8G72PZ-3G2E1
Configured Memory Speed: Unknown
Voltage: Unknown

Size: 64 GB
Locator: DIMM_P0_B1
Bank Locator: BANK
Type: DDR4
Speed: 3200 MT/s
Manufacturer: Micron Technology
Serial Number: XXX
Part Number: 36ASF8G72PZ-3G2E1
Configured Memory Speed: 3200 MT/s
Voltage: 1.2 V

Storage Drives Information
------------------------------------
NAME                 SIZE TYPE  MODEL
sda                447.1G disk  INTEL SSDSC2BB48
├─sda1               501M part
│ └─md127            500M raid1
└─sda2             446.7G part
  └─md126          446.5G raid1
    └─Storage-root 446.5G lvm
sdb                447.1G disk  INTEL SSDSC2BB48
├─sdb1               501M part
│ └─md127            500M raid1
└─sdb2             446.7G part
  └─md126          446.5G raid1
    └─Storage-root 446.5G lvm
nvme0n1              5.8T disk  WUS4CB064XXXP3E3
nvme1n1              5.8T disk  WUS4CB064XXXP3E3
└─nvme1n1p1          5.8T part
  └─md2              5.8T raid1

RAID Information
------------------------------------
ARRAY /dev/md/boot metadata=1.2 name=NMNE-303:boot UUID=da9f7fc4:10ac3853:4fc1c0e0:15d54a67
ARRAY /dev/md/pv00 metadata=1.2 name=NMNE-303:pv00 UUID=9a9c1336:7839ffd3:fa3fa1a4:0fa7f580
ARRAY /dev/md/2 metadata=1.2 name=NMNE-303:2 UUID=6715722d:14b780d1:43af2ac7:499008c0
/dev/md126:
           Version : 1.2
     Creation Time : Fri Jan  1 23:06:02 2021
        Raid Level : raid1
        Array Size : 4682XX544 (446.51 GiB 479.44 GB)
     Used Dev Size : 4682XX544 (446.51 GiB 479.44 GB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Thu Sep  5 04:11:14 2024
             State : active
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : NMNE-303:pv00
              UUID : 9a9c1XXXXX:7839fXXXX:fa3fXXXX:0fa7XXXX
            Events : 29790

    Number   Major   Minor   RaidDevice State
       0       8        2        0      active sync   /dev/sda2
       1       8       18        1      active sync   /dev/sdb2
/dev/md127:
           Version : 1.2
     Creation Time : Fri Jan  1 23:05:57 2021
        Raid Level : raid1
        Array Size : 512000 (500.00 MiB 524.29 MB)
     Used Dev Size : 512000 (500.00 MiB 524.29 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Thu Sep  5 03:42:59 2024
             State : clean
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : NMNE-303:boot
              UUID : da9fXXXXX:10acXXXXX:4fc1XXXXX:15dXXXXX
            Events : 203

    Number   Major   Minor   RaidDevice State
       0       8        1        0      active sync   /dev/sda1
       1       8       17        1      active sync   /dev/sdb1
/dev/md2:
           Version : 1.2
     Creation Time : Sun Jun 25 16:42:04 2023
        Raid Level : raid1
        Array Size : 6251091200 (5.82 TiB 6.40 TB)
     Used Dev Size : 6251091200 (5.82 TiB 6.40 TB)
      Raid Devices : 2
     Total Devices : 1
       Persistence : Superblock is persistent

     Intent Bitmap : Internal

       Update Time : Thu Sep  5 04:11:17 2024
             State : clean, degraded
    Active Devices : 1
   Working Devices : 1
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : bitmap

              Name : NMNE-303:2
              UUID : 671XXXXX:14b78XXXX:43aXXXX:4990XXXXX
            Events : 26860361

    Number   Major   Minor   RaidDevice State
       -       0        0        0      removed
       1     259        2        1      active sync   /dev/nvme1n1p1

Network Card Information
------------------------------------
       product: I350 Gigabit Network Connection
       vendor: Intel Corporation
       serial: XXXX
       size: 100Mbit/s
       capacity: 1Gbit/s
       resources: irq:123 memory:a2520000-XXXX...
       product: I350 Gigabit Network Connection
       vendor: Intel Corporation
       serial: XXXX
       size: 1Gbit/s
       capacity: 1Gbit/s
       resources: irq:192 memory:a2500000-XXXX...

Public IP Addresses
------------------------------------
104.17.110.184

OS and Kernel Information
------------------------------------
Linux hsplshelltestServer02 4.18.0-513.11.1.lve.el8.x86_64 #1 SMP Thu Jan 18 16:21:02 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
NAME="CloudLinux"
VERSION="8.10 (Vladimir Aksyonov)"
ID="cloudlinux"
ID_LIKE="rhel fedora centos"
VERSION_ID="8.10"
PLATFORM_ID="platform:el8"
PRETTY_NAME="CloudLinux 8.10 (Vladimir Aksyonov)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:cloudlinux:cloudlinux:8.10:GA:server"
HOME_URL="https://www.cloudlinux.com/"
BUG_REPORT_URL="https://www.cloudlinux.com/support"
VARIANT_ID="cloudlinux"

Disk Health Status
------------------------------------

Checking health of /dev/sda
SMART overall-health self-assessment test result: PASSED

Checking health of /dev/sdb
SMART overall-health self-assessment test result: PASSED

Checking health of /dev/nvme0n1
SMART overall-health self-assessment test result: PASSED

Checking health of /dev/nvme1n1
SMART overall-health self-assessment test result: PASSED

Power Supply and Motherboard Information
------------------------------------
        Manufacturer: GIGABYTE
        Product

 Name: MZ91-FS0-00

Network Configuration
------------------------------------
Default Gateway:
default via 104.17.110.184 dev eno1

DNS Servers
------------------------------------
NetworkManager is not running. Cannot retrieve DNS server information.
Attempting to retrieve DNS information from /etc/resolv.conf:
8.8.8.8
8.8.4.4

Routing Table
------------------------------------
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         104.17.11.18    0.0.0.0         UG    0      0        0 eno1
104.17.111.11   0.0.0.0         255.255.255.0   U     0      0        0 eno1
104.17.11.18    0.0.0.0         255.255.0.0     U     1002   0        0 eno1

See detailed logs in wits_execution_05-09-2024--04-11-17-raw-output.log for more information.

See summary in server_info_05-09-2024--04-11-17.txt for quick server information.
```


## Customization

You can customize the script further based on your requirements. Feel free to modify the functions or add new sections to capture additional information specific to your use case. Use GitHub to update me on the new stuff related to this script :)

## Troubleshooting

- Ensure the script is run with sufficient permissions (e.g., `sudo`) to access hardware and system information.
- If a package fails to install, you may need to install it manually using your system's package manager.
- The script is designed for RedHat-based systems using `yum` as the package manager. It has cross-compatibility with logic but still, if you face the issue then be sure to check for Debian-based systems, and modify the package management commands accordingly (`apt-get`).

## Contributing

Feel free to fork the repository and submit pull requests for any improvements or additional features. Contributions are always welcome!

## License

This project is licensed under the MIT License.

## Author

Developed by **Dhruval Joshi from HostingSpell**.

Updated here on 5th Sept 2024, 4.48 AM IST.

---
