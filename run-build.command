#!/bin/bash
cd "$(dirname "$0")"
bash rebuild-with-updates.sh
echo ""
echo "Press any key to close..."
read -r
