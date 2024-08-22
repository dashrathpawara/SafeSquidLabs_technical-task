#!/bin/bash

# Function to print messages in color
print_in_color() {
    local color="$1"
    local message="$2"
    case $color in
        "red")
            echo -e "\e[31m$message\e[0m"
            ;;
        "green")
            echo -e "\e[32m$message\e[0m"
            ;;
        "yellow")
            echo -e "\e[33m$message\e[0m"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install necessary network monitoring tools
install_network_tools() {
    print_in_color "yellow" "Installing necessary network monitoring tools..."
    sudo yum install -y net-tools sysstat
    if [ $? -eq 0 ]; then
        print_in_color "green" "Network monitoring tools installed successfully."
    else
        print_in_color "red" "Failed to install network monitoring tools."
    fi
}

# Function to display network monitoring
network_monitor() {
    if ! command_exists ifconfig || ! command_exists netstat; then
        print_in_color "yellow" "Warning: ifconfig or netstat not found. Please install net-tools."
        return
    fi

    print_in_color "green" "Network Monitoring:"
    print_in_color "green" "Concurrent Connections:"
    netstat -an | grep ESTABLISHED | wc -l

    print_in_color "green" "Packet Drops:"
    netstat -s | grep "packet receive errors"

    print_in_color "green" "MB In and Out:"
    ifconfig | grep 'RX bytes' | awk '{print "Received: " $2 " bytes"}'
    ifconfig | grep 'TX bytes' | awk '{print "Transmitted: " $6 " bytes"}'
}

# Main script logic
case "$1" in
    --install-tools)
        install_network_tools
        ;;
    *)
        network_monitor
        ;;
esac
