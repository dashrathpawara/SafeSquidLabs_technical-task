#!/bin/bash

# User and Group Audits
list_users_and_groups() {
  echo "Listing all users and groups:"
  getent passwd
  getent group
}

check_root_users() {
  echo "Checking for users with UID 0:"
  awk -F: '($3 == "0") {print}' /etc/passwd
}

check_users_without_passwords() {
  echo "Checking for users without passwords or with non-standard shells:"
  awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print $1}' /etc/passwd
}

# File and Directory Permissions
scan_world_writable_files() {
  echo "Scanning for world-writable files and directories:"
  find / -perm -002 -type f -exec ls -l {} \;
  find / -perm -002 -type d -exec ls -ld {} \;
}

check_ssh_permissions() {
  echo "Checking .ssh directories for secure permissions:"
  find /home -type d -name ".ssh" -exec chmod 700 {} \;
  find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
}

report_suid_sgid_files() {
  echo "Reporting files with SUID or SGID bits set:"
  find / -perm /6000 -type f -exec ls -l {} \;
}

# Service Audits
list_running_services() {
  echo "Listing all running services:"
  systemctl list-units --type=service --state=running
}

check_critical_services() {
  echo "Checking critical services:"
  systemctl status sshd
  systemctl status iptables
}

check_non_standard_ports() {
  echo "Checking for services listening on non-standard or insecure ports:"
  netstat -tuln | grep -v ':22\|:80\|:443'
}

# Firewall and Network Security
verify_firewall_status() {
  echo "Verifying firewall status:"
  ufw status
  iptables -L
}

# IP vs. Network Configuration Checks
identify_ip_addresses() {
  echo "Identifying public and private IP addresses:"
  ip -o -4 addr list | awk '{print $4}' | while read -r ip; do
    if [[ $ip =~ ^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\. ]]; then
      echo "Private IP: $ip"
    else
      echo "Public IP: $ip"
    fi
  done
}

summarize_ip_addresses() {
  echo "Summary of all IP addresses:"
  ip -o -4 addr list
  ip -o -6 addr list
}

# Security Updates and Patching
ensure_security_updates() {
  echo "Ensuring server is configured for security updates:"
  grep -i "update" /etc/crontab /etc/cron.*/* /var/spool/cron/crontabs/*
}

check_security_updates() {
  echo "Checking for available security updates:"
  if command -v yum &> /dev/null; then
    yum check-update --security
  elif command -v apt-get &> /dev/null; then
    apt-get -s upgrade | grep -i security
  fi
}

# Log Monitoring
monitor_logs() {
  echo "Checking for suspicious log entries:"
  grep "Failed password" /var/log/auth.log
  grep "Invalid user" /var/log/auth.log
}

# Server Hardening Steps
setup_ssh_key_authentication() {
  echo "Setting up SSH key-based authentication and disabling password login for root:"
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  systemctl restart sshd
}

disable_ipv6() {
  echo "Disabling IPv6:"
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
}

update_safesquid() {
  echo "Updating SafeSquid to listen on the correct IPv4 address:"
  sed -i 's/^ListenAddress.*/ListenAddress 0.0.0.0/' /etc/safesquid/safesquid.conf
  systemctl restart safesquid
}

secure_bootloader() {
  echo "Securing the bootloader with a password:"
  grub2-setpassword
}

automate_updates() {
  echo "Automating updates:"
  if command -v yum &> /dev/null; then
    yum install -y yum-cron
    systemctl enable yum-cron
    systemctl start yum-cron
  elif command -v apt-get &> /dev/null; then
    apt-get install -y unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
  fi
}

# Reporting and Alerting
generate_summary_report() {
  echo "Generating summary report:"
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
    ufw status
    iptables -L

    echo "IP vs. Network Configuration Checks:"
    ip -o -4 addr list
    ip -o -6 addr list

    echo "Security Updates and Patching:"
    if command -v yum &> /dev/null; then
      yum check-update --security
    elif command -v apt-get &> /dev/null; then
      apt-get -s upgrade | grep -i security
    fi

    echo "Log Monitoring:"
    grep "Failed password" /var/log/auth.log
    grep "Invalid user" /var/log/auth.log
  } > /var/log/security_audit_report.txt
}

send_email_alerts() {
  echo "Configuring email alerts for critical vulnerabilities:"
  if grep -q "Failed password" /var/log/auth.log; then
    echo "Critical vulnerability found!" | mail -s "Security Alert" admin@example.com
  fi
}

# Main function to call all checks
main() {
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
  send_email_alerts
}

# Execute main function
main
