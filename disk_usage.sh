#!/bin/bash
echo "Disk Usage:"
df -h | grep '^/dev/' | awk '{if ($5+0 > 80) print $0}'
