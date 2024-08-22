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

# Main script logic
service_monitor
