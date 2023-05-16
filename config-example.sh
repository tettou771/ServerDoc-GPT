#!/bin/bash

# GPT version (default: gpt-3.5-turbo)
#gpt="gpt-3.5-turbo"

# Define array of commands
declare -A commands=(
  ["Current time"]="date:Get current date and time."
  ["System uptime"]="uptime:Displays how long the system has been running and the load average."
  ["CPU usage"]="mpstat:Reports detailed CPU usage statistics."
  ["Top processes"]="top -n 1 -b | head -n 20:Displays the top processes by CPU usage. If you find a problem, please write process name with pid."
  ["Disk usage"]="df -h:Displays the disk usage for all files and directories in the root directory."
  ["Memory usage"]="free:Check memory usage."
  ["Virtual memory statistics"]="vmstat:Provides virtual memory statistics including disk IO, system activity, and CPU activity."
  ["IO statistics"]="iostat | grep -v loop:Displays CPU statistics and IO statistics for disks, excluding loop devices."
  ["Recent Kernel messages"]="dmesg -T | tail -30:Displays messages from the kernel, including hardware errors, driver messages, and system errors."
)

# Report mail
#email="your@email.com"

prompt="あなたはサーバー管理者です。サーバの健康状態について日本語でレポートして、オーナーが対応するべきことがあれば教えてください。
最初の行をタイトルにして、20文字以内で表現してください。
2行目から猫のアスキーアートをつけて、深刻度に応じて犬の表情などを変化させてください。
AAの下にレポート本文を書いてください。

最初の行の最初の単語で深刻度を表します。以下の3種類から選んで単語を入れてください。PASSED 以外の時はメールでメッセージが送信される仕組みになっています。
PSSED: 心配なし。
WARNING: 急ぎの対応は不要だが、懸念されることがある。
ERROR: すぐに対応が必要な問題がある。

あなたが送信するメッセージは、コメントアウトなどは不要です。
特に、深刻度の単語の前には何も文字を入れないでください。

また、今日の日付に関連したことをユーモアを交えて何か無駄にひとことつけてください。"

