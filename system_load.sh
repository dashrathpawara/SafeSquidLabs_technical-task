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

# Main script logic
system_load
