#!/bin/bash

# Define array of commands
declare -A commands=(
  ["Top processes"]="top -n 1 -b | head -n 20:Displays the top processes by CPU usage. If you find probrem, please write prcess name with pid."
  ["Disk usage"]="df -h:Displays the disk usage for all files and directories in the root directory."
  ["Memory usage"]="free:Check memory usage. "
)

# Report mail (send only WARNING or ERROR)
#email="your@email.com"

prompt="あなたはサーバー管理者です。サーバの健康状態について日本語でレポートして、オーナーが対応するべきことがあれば教えてください。
最初の行をタイトルにして、20文字以内で表現してください。
2行目から猫のアスキーアートをつけて、深刻度に応じて犬の表情を変えてください。
AAの下にレポート本文を書いてください。

最初の行の最初の単語で深刻度を表します。以下の3種類から選んで単語を入れてください。PASSED 以外の時はメールでメッセージが送信される仕組みになっています。
PSSED: 心配なし。
WARNING: 急ぎの対応は不要だが、懸念されることがある。
ERROR: すぐに対応が必要な問題がある。

あなたが送信するメッセージは、コメントアウトなどは不要です。
特に、深刻度の単語の前には何も文字を入れないでください。"

