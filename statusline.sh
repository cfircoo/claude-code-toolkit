#!/bin/bash
input=$(cat)

# Detect platform and set reverse cat command
if [[ "$OSTYPE" == "darwin"* ]]; then
    TAC_CMD="gtac"  # macOS with coreutils
else
    TAC_CMD="tac"   # Linux
fi

# Extract basic info from JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // empty')
DIR_NAME="${DIR##*/}"
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Get git branch if in a repo
BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
fi

# Colors
GREEN=$'\033[38;5;158m'
YELLOW=$'\033[38;5;215m'
RED=$'\033[38;5;203m'
DIM=$'\033[38;5;240m'
RESET=$'\033[0m'

# Compress number to K/M format
compress_number() {
    local num=$1
    if [ "$num" -lt 1000 ]; then
        echo "$num"
    elif [ "$num" -lt 1000000 ]; then
        local k=$((num / 1000))
        echo "${k}k"
    else
        local m=$((num / 1000000))
        echo "${m}M"
    fi
}

# Create progress bar
progress_bar() {
    local percent=$1
    local len=10
    local filled=$((percent * len / 100))
    local empty=$((len - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="●"; done
    for ((i=0; i<empty; i++)); do bar+="○"; done
    echo "$bar"
}

# Get color based on percentage
get_color() {
    local pct=$1
    if [ "$pct" -ge 70 ]; then
        echo "$RED"
    elif [ "$pct" -ge 50 ]; then
        echo "$YELLOW"
    else
        echo "$GREEN"
    fi
}

# --- Context calculation ---
CTX=""
TOTAL_TOKENS=0

# Method 1: Parse transcript file for actual API usage (most accurate)
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Use tac (Linux) or gtac (macOS) to read file in reverse, find last assistant message with usage
    usage_line=$($TAC_CMD "$TRANSCRIPT_PATH" 2>/dev/null | grep -m 1 '"type":"assistant"')

    if [ -n "$usage_line" ]; then
        usage_data=$(echo "$usage_line" | jq -r '.message.usage // empty' 2>/dev/null)

        if [ -n "$usage_data" ] && [ "$usage_data" != "null" ]; then
            input_tokens=$(echo "$usage_data" | jq -r '.input_tokens // 0')
            cache_create=$(echo "$usage_data" | jq -r '.cache_creation_input_tokens // 0')
            cache_read=$(echo "$usage_data" | jq -r '.cache_read_input_tokens // 0')
            output_tokens=$(echo "$usage_data" | jq -r '.output_tokens // 0')
            TOTAL_TOKENS=$((input_tokens + cache_create + cache_read + output_tokens))
        fi
    fi
fi

# Method 2: Fallback to current_usage from JSON
if [ "$TOTAL_TOKENS" -eq 0 ]; then
    USAGE=$(echo "$input" | jq '.context_window.current_usage' 2>/dev/null)
    if [ "$USAGE" != "null" ] && [ -n "$USAGE" ]; then
        TOTAL_TOKENS=$(echo "$USAGE" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' 2>/dev/null)
    fi
fi

# Build context display
if [ "$TOTAL_TOKENS" -gt 0 ] 2>/dev/null; then
    PERCENT=$((TOTAL_TOKENS * 100 / CONTEXT_SIZE))
    COLOR=$(get_color "$PERCENT")
    BAR=$(progress_bar "$PERCENT")
    COMPRESSED=$(compress_number "$TOTAL_TOKENS")
    MAX_COMPRESSED=$(compress_number "$CONTEXT_SIZE")
    CTX="  ${COLOR}${BAR}${RESET} ${COMPRESSED}/${MAX_COMPRESSED} (${PERCENT}%)"
else
    CTX="  ${DIM}○○○○○○○○○○${RESET} --"
fi

# Get last user prompt from transcript
# Muted sage green instead of bright lime
LIME=$'\033[38;5;108m'
USER_PROMPT=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Find last actual user message (exclude tool_result, commands, system messages)
    user_line=$($TAC_CMD "$TRANSCRIPT_PATH" 2>/dev/null | grep '"type":"user"' | grep -v 'tool_result' | grep -v 'command-name' | grep -v 'local-command' | grep -v 'Caveat:' | head -1)
    if [ -n "$user_line" ]; then
        # Extract content (can be string or array)
        USER_PROMPT=$(echo "$user_line" | jq -r 'if .message.content | type == "string" then .message.content else .message.content[0].text // empty end' 2>/dev/null)
        # Truncate if too long (max 100 chars)
        if [ ${#USER_PROMPT} -gt 100 ]; then
            USER_PROMPT="${USER_PROMPT:0:97}..."
        fi
    fi
fi

# Build status line
LINE1=""
if [ -n "$BRANCH" ]; then
    LINE1=$(printf "🤖 %s  📁 %s  🌿 %s%s" "$MODEL" "$DIR_NAME" "$BRANCH" "$CTX")
else
    LINE1=$(printf "🤖 %s  📁 %s%s" "$MODEL" "$DIR_NAME" "$CTX")
fi

if [ -n "$USER_PROMPT" ]; then
    printf "%s\n${LIME}→ %s${RESET}\n" "$LINE1" "$USER_PROMPT"
else
    printf "%s\n" "$LINE1"
fi
