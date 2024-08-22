#!/bin/bash
echo "Process Monitoring:"
echo "Number of Active Processes:"
ps aux | wc -l

echo "Top 5 Processes by CPU and Memory Usage:"
ps aux --sort=-%cpu,-%mem | head -n 6
