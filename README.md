# This is SET-2 task ,For the SET-1 switch to SET-1 branch
# SafeSquidLabs_technical-task

---

# Automatic Security Audit and Server Hardening Script


## Description

This project involves creating a Bash script to automate security audits and server hardening on Linux servers. The script is designed to be reusable and modular, allowing easy deployment across multiple servers. It includes checks for common security vulnerabilities, private IP identification, and the implementation of IPv4/IPv6 configurations. The final script will be uploaded to a GitHub repository with comprehensive documentation.

## Features

- User and Group Audits
- File and Directory Permissions Checks
- Service Audits
- Firewall and Network Security Verification
- IP vs. Network Configuration Checks
- Security Updates and Patching
- Log Monitoring
- Server Hardening Steps
- Reporting and Alerting

## Installation

1. **Clone the Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. **Make the Script Executable**:
   ```bash
   chmod +x security_audit.sh
   ```

## Usage

Run the script to perform all checks:
```bash
./security_audit.sh
```

### Customizing the Script

You can customize the script by calling only the functions you need. For example, if you only want to perform user and group audits, you can modify the `main` function as follows:

```bash
main() {
  list_users_and_groups
  check_root_users
  check_users_without_passwords
}
```

### Functions

#### User and Group Audits

- **List all users and groups on the server**:
  ```bash
  list_users_and_groups() {
    echo "Listing all users and groups:"
    getent passwd
    getent group
  }
  ```

- **Check for users with UID 0 (root privileges)**:
  ```bash
  check_root_users() {
    echo "Checking for users with UID 0:"
    awk -F: '($3 == "0") {print}' /etc/passwd
  }
  ```

- **Identify users without passwords or with non-standard shells**:
  ```bash
  check_users_without_passwords() {
    echo "Checking for users without passwords or with non-standard shells:"
    awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print $1}' /etc/passwd
  }
  ```

#### File and Directory Permissions

- **Scan for files and directories with world-writable permissions**:
  ```bash
  scan_world_writable_files() {
    echo "Scanning for world-writable files and directories:"
    find / -perm -002 -type f -exec ls -l {} \;
    find / -perm -002 -type d -exec ls -ld {} \;
  }
  ```

- **Check for the presence of .ssh directories and ensure they have secure permissions**:
  ```bash
  check_ssh_permissions() {
    echo "Checking .ssh directories for secure permissions:"
    find /home -type d -name ".ssh" -exec chmod 700 {} \;
    find /home -type f -name "authorized_keys" -exec chmod 600 {} \;
  }
  ```

- **Report any files with SUID or SGID bits set, particularly on executables**:
  ```bash
  report_suid_sgid_files() {
    echo "Reporting files with SUID or SGID bits set:"
    find / -perm /6000 -type f -exec ls -l {} \;
  }
  ```

#### Service Audits

- **List all running services to check for any unnecessary or unauthorized services**:
  ```bash
  list_running_services() {
    echo "Listing all running services:"
    systemctl list-units --type=service --state=running
  }
  ```

- **Ensure that critical services (e.g., sshd, iptables) are running and properly configured**:
  ```bash
  check_critical_services() {
    echo "Checking critical services:"
    systemctl status sshd
    systemctl status iptables
  }
  ```

- **Check that no services are listening on non-standard or insecure ports**:
  ```bash
  check_non_standard_ports() {
    echo "Checking for services listening on non-standard or insecure ports:"
    netstat -tuln | grep -v ':22\|:80\|:443'
  }
  ```

#### Firewall and Network Security

- **Verify that a firewall (e.g., iptables, ufw) is active and configured to block unauthorized access**:
  ```bash
  verify_firewall_status() {
    echo "Verifying firewall status:"
    ufw status
    iptables -L
  }
  ```

#### IP vs. Network Configuration Checks

- **Identify whether the server's IP addresses are public or private**:
  ```bash
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
  ```

- **Provide a summary of all IP addresses assigned to the server**:
  ```bash
  summarize_ip_addresses() {
    echo "Summary of all IP addresses:"
    ip -o -4 addr list
    ip -o -6 addr list
  }
  ```

#### Security Updates and Patching

- **Ensure that the server is configured to receive and install security updates**:
  ```bash
  ensure_security_updates() {
    echo "Ensuring server is configured for security updates:"
    grep -i "update" /etc/crontab /etc/cron.*/* /var/spool/cron/crontabs/*
  }
  ```

- **Check for and report any available security updates or patches**:
  ```bash
  check_security_updates() {
    echo "Checking for available security updates:"
    if command -v yum &> /dev/null; then
      yum check-update --security
    elif command -v apt-get &> /dev/null; then
      apt-get -s upgrade | grep -i security
    fi
  }
  ```

#### Log Monitoring

- **Check for any recent suspicious log entries that may indicate a security breach**:
  ```bash
  monitor_logs() {
    echo "Checking for suspicious log entries:"
    grep "Failed password" /var/log/auth.log
    grep "Invalid user" /var/log/auth.log
  }
  ```

#### Server Hardening Steps

- **Implement SSH key-based authentication and disable password-based login for root**:
  ```bash
  setup_ssh_key_authentication() {
    echo "Setting up SSH key-based authentication and disabling password login for root:"
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  }
  ```

- **Disable IPv6 if not required**:
  ```bash
  disable_ipv6() {
    echo "Disabling IPv6:"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  }
  ```

- **Update services like SafeSquid to listen on the correct IPv4 address**:
  ```bash
  update_safesquid() {
    echo "Updating SafeSquid to listen on the correct IPv4 address:"
    sed -i 's/^ListenAddress.*/ListenAddress 0.0.0.0/' /etc/safesquid/safesquid.conf
    systemctl restart safesquid
  }
  ```

- **Secure the bootloader with a password to prevent unauthorized changes**:
  ```bash
  secure_bootloader() {
    echo "Securing the bootloader with a password:"
    grub2-setpassword
  }
  ```

- **Automate updates**:
  ```bash
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
  ```

#### Reporting and Alerting

- **Generate a summary report of the security audit and hardening process, highlighting any issues that need attention**:
  ```bash
  generate_summary_report() {
    echo "Generating summary report:"
    {
      echo "User and Group Audits:"
      awk -F: '($3 == "0") {print "Root user: "$1}' /etc/passwd
      awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print "User without password or with non-standard shell: "$1}' /etc/passwd

      echo "File
