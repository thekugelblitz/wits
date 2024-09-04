#!/bin/bash

# Script to Check Server/Hardware Information
# Written by: Dhruval Joshi
# Updated on 5th Sept, 4.48 AM IST
# Website: http://HostingSpell.com | http://thedhruval.com
# GitHub: https://github.com/thekugelblitz/wits | Check Guidelines.

# Define log file names with timestamp
TIMESTAMP=$(date +"%d-%m-%Y--%H-%M-%S")
SUMMARY_FILE="server_info_${TIMESTAMP}.txt"
RAW_LOG_FILE="wits_execution_${TIMESTAMP}-raw-output.log"

# Detect package manager
if command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
elif command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
else
    echo "No compatible package manager found. Please install packages manually." | tee -a $SUMMARY_FILE
    exit 1
fi

# Function to set text colors using tput
set_text_color() {
    tput setaf "$1" 2>/dev/null || true
}

# Function to reset text formatting using tput
reset_text_formatting() {
    tput sgr0 2>/dev/null || true
}

# Function to print section headers
print_section() {
    echo -e "\n$(set_text_color 3)$1$(reset_text_formatting)" | tee -a $SUMMARY_FILE
    echo "------------------------------------" | tee -a $SUMMARY_FILE
}

# Function to check and install missing packages
check_and_install_packages() {
    local packages=("redhat-lsb-core" "smartmontools" "dmidecode" "lshw")
    local missing_packages=()
    
    for pkg in "${packages[@]}"; do
        if ! rpm -q $pkg &> /dev/null && ! dpkg -l $pkg &> /dev/null; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "The following required packages are missing:"
        for pkg in "${missing_packages[@]}"; do
            echo "- $pkg"
        done

        read -p "Would you like to install the missing packages? (Y/N): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            for pkg in "${missing_packages[@]}"; do
                echo "Installing $pkg..."
                sudo $PKG_MANAGER install -y $pkg >> $RAW_LOG_FILE 2>&1
                if [ $? -ne 0 ]; then
                    echo "Failed to install $pkg. Please install it manually." | tee -a $SUMMARY_FILE
                fi
            done
        fi
    fi
}

# Function to remove packages that were installed by the script
remove_installed_packages() {
    local packages=("redhat-lsb-core" "smartmontools" "dmidecode" "lshw")
    local installed_packages=()

    for pkg in "${packages[@]}"; do
        if rpm -q $pkg &> /dev/null || dpkg -l $pkg &> /dev/null; then
            installed_packages+=("$pkg")
        fi
    done

    if [ ${#installed_packages[@]} -ne 0 ]; then
        echo "The following packages were installed by this script:"
        for pkg in "${installed_packages[@]}"; do
            echo "- $pkg"
        done

        read -p "Would you like to remove the installed packages? (Y/N): " remove_choice
        if [[ "$remove_choice" =~ ^[Yy]$ ]]; then
            for pkg in "${installed_packages[@]}"; do
                echo "Removing $pkg..."
                sudo $PKG_MANAGER remove -y $pkg >> $RAW_LOG_FILE 2>&1
            done
        fi
    fi
}

# Check and install missing packages if needed
check_and_install_packages

# CPU Information
print_section "CPU Information"
lscpu | egrep 'Thread|Core|Socket|Model name|CPU MHz|CPU max MHz|CPU min MHz' | tee -a $SUMMARY_FILE

# RAM Information with comprehensive parsing
print_section "RAM Information"
dmidecode --type 17 | awk '
/Memory Device/ { memdevice=1; next }
/^$/ { memdevice=0 }
memdevice && /Size: No Module Installed/ { next }
memdevice {
    if ($1 == "Size:" && $2 != "No") { size=$2 " " $3 }
    else if ($1 == "Locator:") { locator=$2 }
    else if ($1 == "Bank") { bank=$3 }
    else if ($1 == "Type:") { type=$2 }
    else if ($1 == "Speed:") { speed=$2 " " $3 }
    else if ($1 == "Manufacturer:") { manufacturer=$2 " " $3 }
    else if ($1 == "Serial") { serial=$3 }
    else if ($1 == "Part") { part=$3 }
    else if ($1 == "Configured" && $2 == "Memory") { configured_speed=$4 " " $5 }
    else if ($1 == "Configured" && $2 == "Voltage:") { voltage=$3 " " $4 }
    else if ($1 == "Error" && $2 == "Correction") { error_correction=$4 " " $5 " " $6 }
    if ($1 == "Part" || $1 == "Size") {
        printf "Size: %s\nLocator: %s\nBank Locator: %s\nType: %s\nSpeed: %s\nManufacturer: %s\nSerial Number: %s\nPart Number: %s\nConfigured Memory Speed: %s\nVoltage: %s\n", size, locator, bank, type, speed, manufacturer, serial, part, configured_speed ? configured_speed : "Unknown", voltage ? voltage : "Unknown"
        if (error_correction) printf "Error Correction Type: %s\n", error_correction
        printf "\n"
        size = ""; locator = ""; bank = ""; type = ""; speed = ""; manufacturer = ""; serial = ""; part = ""; configured_speed = ""; error_correction = ""; voltage = "";
    }
}' | tee -a $SUMMARY_FILE

# Storage Drives Information
print_section "Storage Drives Information"
lsblk -o NAME,SIZE,TYPE,MODEL | tee -a $SUMMARY_FILE

# RAID Information
print_section "RAID Information"
if command -v mdadm &> /dev/null && mdadm --detail --scan | grep -q 'ARRAY'; then
    mdadm --detail --scan 2>/dev/null | grep -v 'cannot be set as name' | tee -a $SUMMARY_FILE
    for array in $(ls /dev/md* 2>/dev/null); do
        mdadm --detail $array 2>/dev/null | grep -v 'cannot be set as name' | tee -a $SUMMARY_FILE
    done
else
    echo "No RAID configuration detected." | tee -a $SUMMARY_FILE
fi

# Network Card Information
print_section "Network Card Information"
if command -v lshw &> /dev/null; then
    lshw -C network | grep -E "product|vendor|serial|size|capacity|resources" | tee -a $SUMMARY_FILE
else
    echo "lshw command not found. Please install it manually." | tee -a $SUMMARY_FILE
fi

# Public IP Addresses
print_section "Public IP Addresses"
hostname -I | tee -a $SUMMARY_FILE

# OS and Kernel Information
print_section "OS and Kernel Information"
uname -a | tee -a $SUMMARY_FILE
cat /etc/os-release | tee -a $SUMMARY_FILE

# Disk Health Status
print_section "Disk Health Status"
for disk in $(lsblk -nd --output NAME); do
    echo -e "\nChecking health of /dev/$disk" | tee -a $SUMMARY_FILE
    smartctl -H /dev/$disk | grep "SMART overall-health self-assessment test result" | tee -a $SUMMARY_FILE
done

# Power Supply and Motherboard Information
print_section "Power Supply and Motherboard Information"
dmidecode --type baseboard | grep -E "Manufacturer|Product Name" | tee -a $SUMMARY_FILE

# Network Configuration
print_section "Network Configuration"

# Print Default Gateway
echo "Default Gateway:" | tee -a $SUMMARY_FILE
ip route | grep default | tee -a $SUMMARY_FILE

# DNS Servers
print_section "DNS Servers"
if systemctl is-active --quiet NetworkManager; then
    nmcli dev show | grep 'IP4.DNS' | awk '{print $2}' | tee -a $SUMMARY_FILE
else
    echo "NetworkManager is not running. Cannot retrieve DNS server information." | tee -a $SUMMARY_FILE
    echo "Attempting to retrieve DNS information from /etc/resolv.conf:" | tee -a $SUMMARY_FILE
    cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}' | tee -a $SUMMARY_FILE
fi

# Print Routing Table
echo "" | tee -a $SUMMARY_FILE
print_section "Routing Table"
route -n | tee -a $SUMMARY_FILE

# Show completion message
echo -e "\nSee detailed logs in $RAW_LOG_FILE for more information."
echo -e "\nSee summary in $SUMMARY_FILE for quick server information."

# Prompt to remove installed packages
remove_installed_packages

# Display the summary file content at the end
print_section "Server Information Summary"
cat $SUMMARY_FILE

# This is the end of it!
