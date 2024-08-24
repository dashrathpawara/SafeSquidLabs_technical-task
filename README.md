# This is SET-2 task ,For the SET-1 switch to SET-1 branch
# SafeSquidLabs_technical-task

---
##Important : I have Amazon linux.
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

## Prerequisites

- **sudo privileges**: The script requires `sudo` privileges to execute many of the commands. Ensure you have the necessary permissions to run the script.

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

Run the script:
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

- List all users and groups on the server.
- Check for users with UID 0 (root privileges).
- Identify users without passwords or with non-standard shells.

#### File and Directory Permissions

- Scan for files and directories with world-writable permissions.
- Check for the presence of .ssh directories and ensure they have secure permissions.
- Report any files with SUID or SGID bits set, particularly on executables.

#### Service Audits

- List all running services to check for any unnecessary or unauthorized services.
- Ensure that critical services (e.g., sshd, iptables) are running and properly configured.
- Check that no services are listening on non-standard or insecure ports.

#### Firewall and Network Security

- Verify that a firewall (e.g., iptables, ufw) is active and configured to block unauthorized access.

#### IP vs. Network Configuration Checks

- Identify whether the server's IP addresses are public or private.
- Provide a summary of all IP addresses assigned to the server.

#### Security Updates and Patching

- Ensure that the server is configured to receive and install security updates.
- Check for and report any available security updates or patches.

#### Log Monitoring

- Check for any recent suspicious log entries that may indicate a security breach.

#### Server Hardening Steps

- Implement SSH key-based authentication and disable password-based login for root.
- Disable IPv6 if not required.
- Update services like SafeSquid to listen on the correct IPv4 address.
- Secure the bootloader with a password to prevent unauthorized changes.
- Automate updates.

#### Reporting and Alerting

- Generate a summary report of the security audit and hardening process, highlighting any issues that need attention.

---

This `README.md` file provides a comprehensive overview of the script, its features, installation process, and usage instructions. Let me know if you need any further adjustments!
