#!/bin/bash

# Define array of commands
declare -A COMMANDS=(
  ["Top processes"]="top -n 1 -b | head -n 20:Displays the top processes by CPU usage"
  ["Disk usage"]="df -h:Displays the disk usage for all files and directories in the root directory"
  ["Memory usage"]="free:Check memory usage"
)


PROMPT="サーバの健康状態について日本語でレポートしてください。緊急で対応する必要がない場合は、最初の行を PASSED にして、懸念されることがある場合は WARNING として、すぐに対応が必要な場合は ERROR にしてください。レポートは3行目から始めてください。"
