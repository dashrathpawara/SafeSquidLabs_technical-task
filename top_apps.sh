#!/bin/bash
echo "Top 10 Applications by CPU and Memory Usage:"
ps aux --sort=-%cpu,-%mem | head -n 11
