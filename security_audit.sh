#!/bin/bash

# Function to check if a service is available and install it if not
check_and_install_service() {
  local service_name=$1
  local package_name=$2

  if ! systemctl is-active --quiet "$service_name"; then
    echo "$service_name is not running. Attempting to install..."
    yum install -y "$package_name"
    if systemctl is-enabled --quiet "$service_name"; then
      echo "$service_name is installed and enabled."
    else
      echo "Failed to install or enable $service_name."
    fi
  else
    echo "$service_name is already running."
  fi
}

# Check and install iptables and firewalld if not available
check_firewall_services() {
  check_and_install_service "iptables" "iptables-services"
  check_and_install_service "firewalld" "firewalld"
}

# User and Group Audits
list_users_and_groups() {
  echo "Starting: Listing all users and groups"
  getent passwd
  getent group
  echo "Completed: Listing all users and groups"
}

check_root_users() {
  echo "Starting: Checking for users with UID 0"
  awk -F: '($3 == "0") {print}' /etc/passwd
  echo "Completed: Checking for users with UID 0"
}

check_users_without_passwords() {
  echo "Starting: Checking for users without passwords or with non-standard shells"
  awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print $1}' /etc/passwd
  echo "Completed: Checking for users without passwords or with non-standard shells"
}

sleep 5

# File and Directory Permissions
scan_world_writable_files() {
  echo "Starting: Scanning for world-writable files and directories"
  find / -perm -002 -type f -exec ls -l {} \;
  find / -perm -002 -type d -exec ls -ld {} \;
  echo "Completed: Scanning for world-writable files and directories"
}

check_ssh_permissions() {
  echo "Starting: Checking .ssh directories for secure permissions"
  find /home -type d -name ".ssh" -exec chmod 700 {} \;
  find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
  echo "Completed: Checking .ssh directories for secure permissions"
}

report_suid_sgid_files() {
  echo "Starting: Reporting files with SUID or SGID bits set"
  find / -perm /6000 -type f -exec ls -l {} \;
  echo "Completed: Reporting files with SUID or SGID bits set"
}

# Service Audits
list_running_services() {
  echo "Starting: Listing all running services"
  systemctl list-units --type=service --state=running
  echo "Completed: Listing all running services"
}

check_critical_services() {
  echo "Starting: Checking critical services"
  systemctl status sshd
  systemctl status iptables
  echo "Completed: Checking critical services"
}

check_non_standard_ports() {
  echo "Starting: Checking for services listening on non-standard or insecure ports"
  netstat -tuln | grep -v ':22\|:80\|:443'
  echo "Completed: Checking for services listening on non-standard or insecure ports"
}

sleep 5

# Firewall and Network Security
verify_firewall_status() {
  echo "Starting: Verifying firewall status"
  systemctl status firewalld
  iptables -L
  echo "Completed: Verifying firewall status"
}

sleep 5

# IP vs. Network Configuration Checks
identify_ip_addresses() {
  echo "Starting: Identifying public and private IP addresses"
  ip -o -4 addr list | awk '{print $4}' | while read -r ip; do
    if [[ $ip =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\. ]]; then
      echo "Private IP: $ip"
    else
      echo "Public IP: $ip"
    fi
  done
  echo "Completed: Identifying public and private IP addresses"
}

summarize_ip_addresses() {
  echo "Starting: Summary of all IP addresses"
  ip -o -4 addr list
  ip -o -6 addr list
  echo "Completed: Summary of all IP addresses"
}

sleep 5

# Security Updates and Patching
ensure_security_updates() {
  echo "Starting: Ensuring server is configured for security updates"
  grep -i "update" /etc/crontab /etc/cron.*/* /var/spool/cron/crontabs/*
  echo "Completed: Ensuring server is configured for security updates"
}

check_security_updates() {
  echo "Starting: Checking for available security updates"
  yum check-update --security
  echo "Completed: Checking for available security updates"
}

# Log Monitoring
monitor_logs() {
  echo "Starting: Checking for suspicious log entries"
  grep "Failed password" /var/log/secure
  grep "Invalid user" /var/log/secure
  echo "Completed: Checking for suspicious log entries"
}

sleep 5

# Server Hardening Steps
setup_ssh_key_authentication() {
  echo "Starting: Setting up SSH key-based authentication and disabling password login for root"
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  systemctl restart sshd
  echo "Completed: Setting up SSH key-based authentication and disabling password login for root"
}

disable_ipv6() {
  echo "Starting: Disabling IPv6"
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "Completed: Disabling IPv6"
}

sleep 5

update_safesquid() {
  echo "Starting: Updating SafeSquid to listen on the correct IPv4 address"
  sed -i 's/^ListenAddress.*/ListenAddress 0.0.0.0/' /etc/safesquid/safesquid.conf
  systemctl restart safesquid
  echo "Completed: Updating SafeSquid to listen on the correct IPv4 address"
}

sleep 5

secure_bootloader() {
  echo "Starting: Securing the bootloader with a password"
  grub2-setpassword
  echo "Completed: Securing the bootloader with a password"
}

sleep 5

automate_updates() {
  echo "Starting: Automating updates"
  # Install dnf-automatic instead of yum-cron for automated updates
  yum install -y dnf-automatic
  systemctl enable dnf-automatic
  systemctl start dnf-automatic
  echo "Completed: Automating updates"
}

sleep 5

# Reporting and Alerting
generate_summary_report() {
  echo "Starting: Generating summary report"
  {
    echo "User and Group Audits:"
    awk -F: '($3 == "0") {print "Root user: "$1}' /etc/passwd
    awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print "User without password or with non-standard shell: "$1}' /etc/passwd

    echo "File and Directory Permissions:"
    find / -perm -002 -type f -exec ls -l {} \;
    find / -perm -002 -type d -exec ls -ld {} \;
    find / -perm /6000 -type f -exec ls -l {} \;

    echo "Service Audits:"
    systemctl list-units --type=service --state=running
    netstat -tuln | grep -v ':22\|:80\|:443'

    echo "Firewall and Network Security:"
    systemctl status firewalld
    iptables -L

    echo "IP vs. Network Configuration Checks:"
    ip -o -4 addr list
    ip -o -6 addr list

    echo "Security Updates and Patching:"
    yum check-update --security

    echo "Log Monitoring:"
    grep "Failed password" /var/log/secure
    grep "Invalid user" /var/log/secure
  } > /var/log/security.log
  echo "Completed: Generating summary report"
}

# Main function to call all checks
main() {
  check_firewall_services
  list_users_and_groups
  check_root_users
  check_users_without_passwords
  scan_world_writable_files
  check_ssh_permissions
  report_suid_sgid_files
  list_running_services
  check_critical_services
  check_non_standard_ports
  verify_firewall_status
  identify_ip_addresses
  summarize_ip_addresses
  ensure_security_updates
  check_security_updates
  monitor_logs
  setup_ssh_key_authentication
  disable_ipv6
  update_safesquid
 }
 main
