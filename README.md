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
   git clone <SafeSquidLabs_technical-task>
   cd <SafeSquidLabs_technical-task
>
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

## Requirements and Commands

### 1. User and Group Audits

- **List all users and groups on the server**:
  - `getent passwd` to list all users.
  - `getent group` to list all groups.

- **Check for users with UID 0 (root privileges)**:
  - `awk -F: '($3 == "0") {print}' /etc/passwd` to find users with UID 0.

- **Identify users without passwords or with non-standard shells**:
  - `awk -F: '($2 == "" || $7 !~ /\/bin\/(bash|sh)/) {print $1}' /etc/passwd` to find users without passwords or with non-standard shells.

### 2. File and Directory Permissions

- **Scan for files and directories with world-writable permissions**:
  - `find / -perm -002 -type f -exec ls -l {} \;` to find world-writable files.
  - `find / -perm -002 -type d -exec ls -ld {} \;` to find world-writable directories.

- **Check for the presence of .ssh directories and ensure they have secure permissions**:
  - `find /home -type d -name ".ssh" -exec chmod 700 {} \;` to set secure permissions on .ssh directories.
  - `find /home -type f -name "authorized_keys" -exec chmod 600 {} \;` to set secure permissions on authorized_keys files.

- **Report any files with SUID or SGID bits set, particularly on executables**:
  - `find / -perm /6000 -type f -exec ls -l {} \;` to find files with SUID or SGID bits set.

### 3. Service Audits

- **List all running services to check for any unnecessary or unauthorized services**:
  - `systemctl list-units --type=service --state=running` to list all running services.

- **Ensure that critical services (e.g., sshd, iptables) are running and properly configured**:
  - `systemctl status sshd` to check the status of the SSH service.
  - `systemctl status iptables` to check the status of the iptables service.

- **Check that no services are listening on non-standard or insecure ports**:
  - `netstat -tuln | grep -v ':22\|:80\|:443'` to find services listening on non-standard or insecure ports.

### 4. Firewall and Network Security

- **Verify that a firewall (e.g., iptables, ufw) is active and configured to block unauthorized access**:
  - `ufw status` to check the status of the UFW firewall.
  - `iptables -L` to list the current iptables rules.

### 5. IP vs. Network Configuration Checks

- **Identify whether the server's IP addresses are public or private**:
  - `ip -o -4 addr list | awk '{print $4}'` to list IPv4 addresses.
  - `ip -o -6 addr list | awk '{print $4}'` to list IPv6 addresses.
  - Check if the IP addresses fall within private IP ranges (e.g., 10.x.x.x, 172.16.x.x - 172.31.x.x, 192.168.x.x).

- **Provide a summary of all IP addresses assigned to the server**:
  - `ip -o -4 addr list` to list all IPv4 addresses.
  - `ip -o -6 addr list` to list all IPv6 addresses.

### 6. Security Updates and Patching

- **Ensure that the server is configured to receive and install security updates**:
  - Check cron jobs for update commands using `grep -i "update" /etc/crontab /etc/cron.*/* /var/spool/cron/crontabs/*`.

- **Check for and report any available security updates or patches**:
  - `yum check-update --security` for systems using yum.
  - `apt-get -s upgrade | grep -i security` for systems using apt-get.

### 7. Log Monitoring

- **Check for any recent suspicious log entries that may indicate a security breach**:
  - `grep "Failed password" /var/log/auth.log` to find failed SSH login attempts.
  - `grep "Invalid user" /var/log/auth.log` to find attempts to log in with invalid users.

### 8. Server Hardening Steps

- **Implement SSH key-based authentication and disable password-based login for root**:
  - Edit `/etc/ssh/sshd_config` to set `PermitRootLogin prohibit-password` and `PasswordAuthentication no`.
  - Restart the SSH service using `systemctl restart sshd`.

- **Disable IPv6 if not required**:
  - Use `sysctl -w net.ipv6.conf.all.disable_ipv6=1` and `sysctl -w net.ipv6.conf.default.disable_ipv6=1` to disable IPv6.
  - Add `net.ipv6.conf.all.disable_ipv6 = 1` and `net.ipv6.conf.default.disable_ipv6 = 1` to `/etc/sysctl.conf`.

- **Update services like SafeSquid to listen on the correct IPv4 address**:
  - Edit `/etc/safesquid/safesquid.conf` to set `ListenAddress 0.0.0.0`.
  - Restart the SafeSquid service using `systemctl restart safesquid`.

- **Secure the bootloader with a password to prevent unauthorized changes**:
  - Use `grub2-setpassword` to set a password for the bootloader.

- **Automate updates**:
  - For systems using yum, install and enable yum-cron using `yum install -y yum-cron` and `systemctl enable yum-cron`.
  - For systems using apt-get, install and configure unattended-upgrades using `apt-get install -y unattended-upgrades` and `dpkg-reconfigure -plow unattended-upgrades`.

### 10. Reporting and Alerting

- **Generate a summary report of the security audit and hardening process, highlighting any issues that need attention**:
  - Collect and summarize the output of the above commands into a report file, e.g., `/var/log/security_audit_report.txt`.

- **Optionally, configure the script to send email alerts or notifications if critical vulnerabilities or misconfigurations are found**:
  - Use `mail` command to send alerts, e.g., `echo "Critical vulnerability found!" | mail -s "Security Alert" admin@example.com`.

## Example Configuration Files

- `example_config.conf`: Template for customizing security checks and hardening measures.

## License

This project is licensed under the MIT License.

---

Feel free to customize the commands and steps as needed for your specific environment. Let me know if you need any further assistance!
