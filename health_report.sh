#!/bin/bash

# check jq command exists
if ! which jq >/dev/null; then
  echo "jqコマンドがインストールされていません。jqコマンドをインストールしてください。"
  echo "例: sudo apt-get install jq"
  exit 1
fi

# check API_KEY
if [ -z "$1" ]; then
  echo "Error: API_KEY is missing."
  echo "Usage: $0 <API_KEY>"
  exit 1
fi

# Load settings from config file
CONFIG_FILE="$(dirname "$0")/config.sh"
CONFIG_EXAMPLE_FILE="$(dirname "$0")/config-example.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_EXAMPLE_FILE" "$CONFIG_FILE"
fi

source "$(dirname "$0")/config.sh"

# Define function to execute a command and format the output
execute_command() {
  title="$1"
  cmd="$2"
  description="$3"
  
  output=$(eval $cmd)
  
#  echo "### $title"
#  echo "\`\`\`"
#  echo "$cmd"
#  echo "$output"
#  echo "\`\`\`"
#  echo ""
  
#  if [ -n "$description" ]; then
#    echo "$description"
#    echo ""
#  fi
}

# Main script

# Combine output of all commands into single string
output=""
for title in "${!COMMANDS[@]}"; do
  # コロンで区切られたコマンドと説明文を抽出
  cmd_and_desc=${COMMANDS["$title"]}
  IFS=":" read -ra cmd_and_desc_arr <<< "$cmd_and_desc"
  cmd="${cmd_and_desc_arr[0]}"
  desc="${cmd_and_desc_arr[1]}"
  execute_command "$title" "${cmd_and_desc_arr[0]}" "${cmd_and_desc_arr[1]}"
  output+="### ${command[0]}\n\`\`\`\n${command[1]}\n${output}\n\`\`\`\n\n${command[2]}\n\n"
done

json_escape() {
  printf '%s' "$1" | jq -Rs .
}

# Use the function to escape your $output variable
escaped_prompt=$(json_escape "$PROMPT")
escaped_output=$(json_escape "$output")

# Send request to API
API_KEY=$1

dummy="Hello,GPT!"
# Define messages for conversation
messages=(
  "{\"role\": \"system\", \"content\": $escaped_prompt}"
  "{\"role\": \"user\", \"content\": $escaped_output}"
)

# Convert messages array to a JSON string
messages_json="["$(IFS=,; echo "${messages[*]}")"]"

# Send a request to the OpenAI API using GPT-3.5-turbo
RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": '"$messages_json"',
    "max_tokens": 200,
    "n": 1,
    "stop": null,
    "temperature": 0.5
  }')

#echo "Response: $RESPONSE"

# Check response status code
RESPONSE_CODE=$(echo $RESPONSE | jq -r '.code')
if [ "$RESPONSE_CODE" != "null" ]; then
  echo "Failed to generate text. Response code: $RESPONSE_CODE"
  exit 1
fi

# Parse response and print generated text
GENERATED_TEXT=$(echo $RESPONSE | jq -r '.choices[].message.content')
echo $GENERATED_TEXT

