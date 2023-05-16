#!/bin/bash

##----------------
## Prepare parametors
##----------------

# check jq command exists
if ! which jq >/dev/null; then
  echo "jqコマンドがインストールされていません。jqコマンドをインストールしてください。"
  echo "例: sudo apt-get install jq"
  exit 1
fi

# check api_key
if [ -z "$1" ]; then
  echo "Error: api_key is missing."
  echo "Usage: $0 <api_key>"
  exit 1
fi

# Load settings from config file
config_file="$(dirname "$0")/config.sh"
config_example_file="$(dirname "$0")/config-example.sh"

if [ ! -f "$config_file" ]; then
  cp "$config_example_file" "$config_file"
fi

: ${gpt:=gpt-3.5-turbo}

source "$(dirname "$0")/config.sh"
 
##----------------
## Exec health check commands
##----------------

# Define function to execute a command and format the output
execute_command() {
  title="$1"
  cmd="$2"
  description="$3"
  
  output+="## $title\n"
  output+="## $description\n\n"
  output+="$cmd\n\n"
  output+=$(eval $cmd)
  output+="\n\n"
}

# Combine output of all commands into single string
output=""
for title in "${!commands[@]}"; do
  # コロンで区切られたコマンドと説明文を抽出
  cmd_and_desc=${commands["$title"]}
  IFS=":" read -ra cmd_and_desc_arr <<< "$cmd_and_desc"
  cmd="${cmd_and_desc_arr[0]}"
  desc="${cmd_and_desc_arr[1]}"
  execute_command "$title" "$cmd" "$desc"
done

##----------------
## Make HTTP request
##----------------

json_escape() {
  printf '%s' "$1" | jq -Rs .
}

# Use the function to escape your $output variable
escaped_prompt=$(json_escape "$prompt")
escaped_output=$(json_escape "$output")

# Send request to API
api_key=$1

dummy="Hello,GPT!"
# Define messages for conversation
messages=(
  "{\"role\": \"system\", \"content\": $escaped_prompt}"
  "{\"role\": \"user\", \"content\": $escaped_output}"
)

# Convert messages array to a JSON string
messages_json="["$(IFS=,; echo "${messages[*]}")"]"

##----------------
## Ask to GPT
##----------------

# Send a request to the OpenAI API
response=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $api_key" \
  -d '{
    "model": "'"$gpt"'",
    "messages": '"$messages_json"',
    "max_tokens": 200,
    "n": 1,
    "stop": null,
    "temperature": 0.5
  }')

echo "Response: $response"

# Check response status code
response_code=$(echo $response | jq -r '.code')
if [ "$response_code" != "null" ]; then
  echo "Failed to generate text. Response code: $response_code"
  exit 1
fi

# Parse response and print generated text
gpt_answer=$(echo $response | jq -r '.choices[].message.content')
echo $gpt_answer

##----------------
## Log file
##----------------

# Extract the title and body from gpt_answer
title=$(echo "$gpt_answer" | head -n 1)
body=$(echo "$gpt_answer" | tail -n +2)

# Set log directory in user's home directory
log_dir="${HOME}/ServerDoc-GPT_logs"

# Create 'log' directory if it doesn't exist
mkdir -p $log_dir

# Get current date and time
current_datetime=$(date "+%Y-%m-%d_%H-%M-%S")

# Set log file name based on the title (PASSED, WARNING, or ERROR)
log_filepath="${log_dir}/${current_datetime}_${title}.log"

# Save the log
echo -e "Title: ${title}\n\nBody:\n${body}\n\n${output}" > "$log_filepath"

##----------------
## Send mail
##----------------

# Add output to the body
body=$(echo -e "${body}\n\n${output}")

# Send email using mail command
echo -e "$body" | mail -s "ServerDoc-GPT $title" "$email"


