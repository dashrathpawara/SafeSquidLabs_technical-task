#!/bin/bash

# Function to check if the user has sudo privileges
check_sudo() {
  if sudo -n true 2>/dev/null; then
    echo "User has sudo privileges."
  else
    echo "User does not have sudo privileges. Please run this script with a user that has sudo privileges."
    exit 1
  fi
}

# Function to prompt for sudo password and switch to sudo user
run_with_sudo() {
  echo "Please enter your sudo password:"
  sudo -v
  if [ $? -ne 0 ]; then
    echo "Incorrect sudo password. Exiting."
    exit 1
  fi
}

# User and Group Audits
list_users_and_groups() {
  echo "Listing all users and groups:"
  sudo getent passwd
  sudo getent group
}

check_root_users() {
  echo "Checking for users with UID 0:"
  sudo awk -F: '($3 == "0") {print}' /etc/passwd
}

check_users_without_passwords() {
  echo "Checking for users without passwords or with non-standard shells:"
  sudo awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print $1}' /etc/passwd
}

# File and Directory Permissions
scan_world_writable_files() {
  echo "Scanning for world-writable files and directories:"
  sudo find / -perm -002 -type f -exec ls -l {} \;
  sudo find / -perm -002 -type d -exec ls -ld {} \;
}

check_ssh_permissions() {
  echo "Checking .ssh directories for secure permissions:"
  sudo find /home -type d -name ".ssh" -exec chmod 700 {} \;
  sudo find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
}

report_suid_sgid_files() {
  echo "Reporting files with SUID or SGID bits set:"
  sudo find / -perm /6000 -type f -exec ls -l {} \;
}

# Service Audits
list_running_services() {
  echo "Listing all running services:"
  sudo systemctl list-units --type=service --state=running
}

check_critical_services() {
  echo "Checking critical services:"
  sudo systemctl status sshd
  sudo systemctl status iptables
}

check_non_standard_ports() {
  echo "Checking for services listening on non-standard or insecure ports:"
  sudo netstat -tuln | grep -v ':22\|:80\|:443'
}

# Firewall and Network Security
verify_firewall_status() {
  echo "Verifying firewall status:"
  sudo systemctl status firewalld
  sudo iptables -L
}

# IP vs. Network Configuration Checks
identify_ip_addresses() {
  echo "Identifying public and private IP addresses:"
  sudo ip -o -4 addr list | awk '{print $4}' | while read -r ip; do
    if [[ $ip =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\. ]]; then
      echo "Private IP: $ip"
    else
      echo "Public IP: $ip"
    fi
  done
}

summarize_ip_addresses() {
  echo "Summary of all IP addresses:"
  sudo ip -o -4 addr list
  sudo ip -o -6 addr list
}

# Security Updates and Patching
ensure_security_updates() {
  echo "Ensuring server is configured for security updates:"
  sudo grep -i "update" /etc/crontab /etc/cron.*/* /var/spool/cron/crontabs/*
}

check_security_updates() {
  echo "Checking for available security updates:"
  sudo yum check-update --security
}

# Log Monitoring
monitor_logs() {
  echo "Checking for suspicious log entries:"
  sudo grep "Failed password" /var/log/secure
  sudo grep "Invalid user" /var/log/secure
}

# Server Hardening Steps
setup_ssh_key_authentication() {
  echo "Setting up SSH key-based authentication and disabling password login for root:"
  sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  sudo systemctl restart sshd
}

disable_ipv6() {
  echo "Disabling IPv6:"
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
  echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
}

update_safesquid() {
  echo "Updating SafeSquid to listen on the correct IPv4 address:"
  sudo sed -i 's/^ListenAddress.*/ListenAddress 0.0.0.0/' /etc/safesquid/safesquid.conf
  sudo systemctl restart safesquid
}

secure_bootloader() {
  echo "Securing the bootloader with a password:"
  sudo grub2-setpassword
}

automate_updates() {
  echo "Automating updates:"
  sudo yum install -y yum-cron
  sudo systemctl enable yum-cron
  sudo systemctl start yum-cron
}

# Reporting and Alerting
generate_summary_report() {
  echo "Generating summary report:"
  {
    echo "User and Group Audits:"
    sudo awk -F: '($3 == "0") {print "Root user: "$1}' /etc/passwd
    sudo awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print "User without password or with non-standard shell: "$1}' /etc/passwd

    echo "File and Directory Permissions:"
    sudo find / -perm -002 -type f -exec ls -l {} \;
    sudo find / -perm -002 -type d -exec ls -ld {} \;
    sudo find / -perm /6000 -type f -exec ls -l {} \;

    echo "Service Audits:"
    sudo systemctl list-units --type=service --state=running
    sudo netstat -tuln | grep -v ':22\|:80\|:443'

    echo "Firewall and Network Security:"
    sudo systemctl status firewalld
    sudo iptables -L

    echo "IP vs. Network Configuration Checks:"
    sudo ip -o -4 addr list
    sudo ip -o -6 addr list

    echo "Security Updates and Patching:"
    sudo yum check-update --security

    echo "Log Monitoring:"
    sudo grep "Failed password" /var/log/secure
    sudo grep "Invalid user" /var/log/secure
  } > /var/log/security.log
}

# Main function to call all checks
main() {
  check_sudo
  run_with_sudo
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
  secure_bootloader
  automate_updates
  generate_summary_report
}

# Execute main function
main
