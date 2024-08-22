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

# Function to display top 10 applications by CPU and memory usage
top_apps() {
    print_in_color "green" "Top 10 Applications by CPU and Memory Usage:"
    ps aux --sort=-%cpu,-%mem | head -n 11
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

# Function to display disk usage
disk_usage() {
    print_in_color "green" "Disk Usage:"
    df -h | grep '^/dev/' | awk '{if ($5+0 > 80) print $0}'
}

# Function to display system load
system_load() {
    if ! command_exists mpstat; then
        print_in_color "yellow" "Warning: mpstat not found. Please install sysstat."
        return
    fi

    print_in_color "green" "System Load:"
    uptime

    print_in_color "green" "CPU Usage Breakdown:"
    mpstat
}

# Function to display memory usage
memory_usage() {
    print_in_color "green" "Memory Usage:"
    free -h

    print_in_color "green" "Swap Memory Usage:"
    swapon --show
}

# Function to display process monitoring
process_monitor() {
    print_in_color "green" "Process Monitoring:"
    print_in_color "green" "Number of Active Processes:"
    ps aux | wc -l

    print_in_color "green" "Top 5 Processes by CPU and Memory Usage:"
    ps aux --sort=-%cpu,-%mem | head -n 6
}

# Function to display service monitoring
service_monitor() {
    print_in_color "green" "Service Monitoring:"
    services=("sshd" "nginx" "apache2" "iptables")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            print_in_color "green" "$service is running"
        else
            print_in_color "red" "$service is not running"
        fi
    done
}

# Function to display the dashboard
dashboard() {
    clear
    print_in_color "green" "System Resource Dashboard"
    print_in_color "green" "-------------------------"
    top_apps
    print_in_color "green" "-------------------------"
    network_monitor
    print_in_color "green" "-------------------------"
    disk_usage
    print_in_color "green" "-------------------------"
    system_load
    print_in_color "green" "-------------------------"
    memory_usage
    print_in_color "green" "-------------------------"
    process_monitor
    print_in_color "green" "-------------------------"
    service_monitor
    print_in_color "green" "-------------------------"
}

# Main script logic
while true; do
    case "$1" in
        --install-tools)
            install_network_tools
            ;;
        --top-apps)
            top_apps
            ;;
        --network)
            network_monitor
            ;;
        --disk)
            disk_usage
            ;;
        --load)
            system_load
            ;;
        --memory)
            memory_usage
            ;;
        --process)
            process_monitor
            ;;
        --service)
            service_monitor
            ;;
        *)
            dashboard
            ;;
    esac
    sleep 20
    [ -z "$1" ] && clear
done
