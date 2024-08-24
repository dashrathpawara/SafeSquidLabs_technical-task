# This is SET-1 Tasks. 
**For the SET-2 Tasks switch to SET-2 branch**
# SafeSquidLabs_technical-task
This project provides a comprehensive Bash script designed to monitor various system resources on a proxy server. The script offers real-time insights into system performance, ensuring efficient resource management and quick identification of potential issues.
---

# Monitoring System Resources for a Proxy Server

## Introduction
This Bash script monitors various system resources and presents them in a dashboard format. The script refreshes the data every 20 seconds, providing real-time insights. Additionally, it allows users to call specific parts of the dashboard individually using command-line switches.

### Requirements

1. **Top 10 Most Used Applications**
   - **Description**: This script identifies and displays the top 10 applications that are consuming the most CPU and memory resources on the system.
   - **Purpose**: Helps in identifying resource-hungry applications that might be affecting the performance of the proxy server.
   - **Command Used**: `ps aux --sort=-%cpu,-%mem | head -n 11`
   - **Output**: A list of the top 10 applications sorted by CPU and memory usage.

2. **Network Monitoring**
   - **Description**: This script monitors network activity, including the number of concurrent connections, packet drops, and the amount of data received and transmitted.
   - **Purpose**: Provides insights into network performance and potential issues such as high traffic or packet loss.
   - **Commands Used**:
     - `netstat -an | grep ESTABLISHED | wc -l`: Counts the number of established connections.
     - `netstat -s | grep "packet receive errors"`: Displays packet receive errors.
     - `ifconfig | grep 'RX bytes'`: Shows the amount of data received.
     - `ifconfig | grep 'TX bytes'`: Shows the amount of data transmitted.
   - **Output**: Information on concurrent connections, packet drops, and data transfer.

3. **Disk Usage**
   - **Description**: This script checks the disk space usage of mounted partitions and highlights partitions that are using more than 80% of their capacity.
   - **Purpose**: Helps in monitoring disk space to prevent issues related to insufficient storage.
   - **Command Used**: `df -h | grep '^/dev/' | awk '{if ($5+0 > 80) print $0}'`
   - **Output**: A list of partitions with their usage percentages, highlighting those above 80%.

4. **System Load**
   - **Description**: This script displays the current system load average and provides a breakdown of CPU usage.
   - **Purpose**: Helps in understanding the overall load on the system and identifying potential performance bottlenecks.
   - **Commands Used**:
     - `uptime`: Shows the current load average.
     - `mpstat`: Provides a detailed breakdown of CPU usage.
   - **Output**: Load average and CPU usage statistics.

5. **Memory Usage**
   - **Description**: This script displays the total, used, and free memory, as well as swap memory usage.
   - **Purpose**: Helps in monitoring memory usage to ensure the system has enough free memory for optimal performance.
   - **Commands Used**:
     - `free -h`: Displays memory usage in a human-readable format.
     - `swapon --show`: Shows swap memory usage.
   - **Output**: Memory and swap usage statistics.

6. **Process Monitoring**
   - **Description**: This script displays the number of active processes and the top 5 processes by CPU and memory usage.
   - **Purpose**: Helps in identifying the most resource-intensive processes and monitoring the overall process count.
   - **Commands Used**:
     - `ps aux | wc -l`: Counts the number of active processes.
     - `ps aux --sort=-%cpu,-%mem | head -n 6`: Lists the top 5 processes by CPU and memory usage.
   - **Output**: Number of active processes and a list of the top 5 processes.

7. **Service Monitoring**
   - **Description**: This script checks the status of essential services like `sshd`, `nginx/apache`, and `iptables`.
   - **Purpose**: Ensures that critical services are running and alerts if any service is not active.
   - **Command Used**: `systemctl is-active --quiet $service && echo "$service is running" || echo "$service is not running"`
   - **Output**: Status of each monitored service.

8. **Custom Dashboard**
   - **Description**: This script provides a dashboard view of system resources, combining all the above monitoring aspects. It allows users to view specific parts of the dashboard using command-line switches.
   - **Purpose**: Offers a comprehensive and customizable view of system performance, making it easier to monitor and manage resources.
   - **Commands Used**: Combines all the commands from the individual scripts.
   - **Output**: A dashboard displaying top applications, network statistics, disk usage, system load, memory usage, process monitoring, and service status.

### Installation
## Update the system and install git 
1. Clone the repository or download the script file.
2. Make the script executable:
   ```bash
   chmod +x monitor.sh
   ```

### Configuration
- No specific configuration is required. The script uses standard system commands to gather data.

### Usage
- Run the script without any arguments to display the full dashboard:
  ```bash
  ./monitor.sh
  ```
- Use command-line switches to view specific parts of the dashboard:
  ```bash
  ./monitor.sh --top-apps
  ./monitor.sh --network
  ./monitor.sh --disk
  ./monitor.sh --load
  ./monitor.sh --memory
  ./monitor.sh --process
  ./monitor.sh --service
  ```

### Customization
- Extend the script by adding new functions or modifying existing ones to monitor additional resources.
- Modify the `dashboard` function to include new sections or remove existing ones.

### Support & Contribution
- For support, open an issue on the repository.
- Contributions are welcome! Please fork the repository and submit a pull request.

### Contact Information
- For more information or support, contact the project maintainer at [dashrathpawara1997@gmail.com]
