#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop
# Usage: ./ralph.sh [max_iterations]
#
# Exit codes:
#   0 - All stories completed
#   1 - Max iterations reached
#   2 - All remaining stories blocked or exhausted (maxAttempts exceeded)

set -e

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

# Project files (under tasks/ directory)
TASKS_DIR="$PROJECT_DIR/tasks"
mkdir -p "$TASKS_DIR"
PRD_FILE="$TASKS_DIR/prd.json"
PROGRESS_FILE="$TASKS_DIR/progress.txt"
ARCHIVE_DIR="$TASKS_DIR/.ralph-archive"
LAST_BRANCH_FILE="$TASKS_DIR/.ralph-last-branch"
LOG_FILE="$TASKS_DIR/ralph.log"

# Logging: write to both stdout and log file
log() {
  echo "$@" | tee -a "$LOG_FILE"
}

# Start fresh log for this run
echo "=== Ralph run started: $(date) ===" > "$LOG_FILE"
echo "Max iterations: $MAX_ITERATIONS" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Check that prd.json exists
if [ ! -f "$PRD_FILE" ]; then
  echo "Error: prd.json not found at $PRD_FILE"
  echo ""
  echo "Create prd.json with user stories first. Use /ralph-convert-prd to generate it."
  exit 1
fi

# Archive previous run if branch changed
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    # Archive the previous run
    DATE=$(date +%Y-%m-%d)
    # Strip "ralph/" prefix from branch name for folder
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    # Reset progress file for new run
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# Print status summary from prd.json
print_status() {
  echo ""
  echo "┌─────────────────────────────────────────────────┐"
  echo "│  Story Status Summary                           │"
  echo "├─────────────────────────────────────────────────┤"

  # Support both new (status) and old (passes) schema
  local has_status=$(jq 'any(.userStories[]; .status != null)' "$PRD_FILE" 2>/dev/null || echo "false")

  if [ "$has_status" = "true" ]; then
    local total=$(jq '.userStories | length' "$PRD_FILE")
    local done=$(jq '[.userStories[] | select(.status == "done")] | length' "$PRD_FILE")
    local failed=$(jq '[.userStories[] | select(.status == "failed")] | length' "$PRD_FILE")
    local in_progress=$(jq '[.userStories[] | select(.status == "in_progress")] | length' "$PRD_FILE")
    local pending=$(jq '[.userStories[] | select(.status == "pending")] | length' "$PRD_FILE")
    local blocked=$(jq '[.userStories[] | select(.status == "blocked")] | length' "$PRD_FILE")
    local exhausted=$(jq '[.userStories[] | select(.status == "failed" and .attempts >= .maxAttempts)] | length' "$PRD_FILE" 2>/dev/null || echo "0")

    printf "│  done: %-3s  pending: %-3s  failed: %-3s        │\n" "$done" "$pending" "$failed"
    printf "│  in_progress: %-3s  blocked: %-3s               │\n" "$in_progress" "$blocked"
    printf "│  total: %-3s  exhausted: %-3s                   │\n" "$total" "$exhausted"
  else
    # Old schema with passes boolean
    local total=$(jq '.userStories | length' "$PRD_FILE")
    local passed=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE")
    local remaining=$((total - passed))
    printf "│  passed: %-3s  remaining: %-3s  total: %-3s      │\n" "$passed" "$remaining" "$total"
  fi

  echo "└─────────────────────────────────────────────────┘"
}

# Check if all remaining stories are exhausted (maxAttempts exceeded)
check_exhausted() {
  local has_status=$(jq 'any(.userStories[]; .status != null)' "$PRD_FILE" 2>/dev/null || echo "false")

  if [ "$has_status" = "true" ]; then
    local incomplete=$(jq '[.userStories[] | select(.status != "done")] | length' "$PRD_FILE")
    local exhausted=$(jq '[.userStories[] | select(.status == "failed" and .attempts >= .maxAttempts)] | length' "$PRD_FILE" 2>/dev/null || echo "0")
    local blocked=$(jq '[.userStories[] | select(.status == "blocked")] | length' "$PRD_FILE" 2>/dev/null || echo "0")

    if [ "$incomplete" -gt 0 ] && [ "$((exhausted + blocked))" -ge "$incomplete" ]; then
      return 0  # All stuck
    fi
  fi
  return 1
}

log "Starting Ralph - Max iterations: $MAX_ITERATIONS"
print_status

for i in $(seq 1 $MAX_ITERATIONS); do
  log ""
  log "═══════════════════════════════════════════════════════"
  log "  Ralph Iteration $i of $MAX_ITERATIONS"
  log "═══════════════════════════════════════════════════════"

  # Log which story is next (before spawning Claude)
  NEXT_STORY=$(jq -r '[.userStories[] | select(.status == "pending" or (.status == "failed" and .attempts < .maxAttempts))] | sort_by(.priority) | .[0] | "\(.id): \(.title)"' "$PRD_FILE" 2>/dev/null || echo "unknown")
  log "  Picking up: $NEXT_STORY"
  log ""

  # Run claude with the ralph prompt
  OUTPUT=$(claude --dangerously-skip-permissions -p "$(cat "$SCRIPT_DIR/prompt.md")" 2>&1 | tee -a "$LOG_FILE" | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    log ""
    print_status
    log ""
    log "Ralph completed all tasks!"
    log "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  # Check for blocked signal
  if echo "$OUTPUT" | grep -q "<promise>BLOCKED</promise>"; then
    log ""
    print_status
    log ""
    log "Ralph is BLOCKED - all remaining stories have exceeded maxAttempts or are blocked."
    log "Check progress.txt and prd.json for details."
    exit 2
  fi

  # Print status after iteration
  print_status

  # Check if all stories are stuck
  if check_exhausted; then
    log ""
    log "WARNING: All remaining stories are exhausted or blocked."
    log "Ralph will continue but is unlikely to make progress."
    log "Consider reviewing failed stories in prd.json."
  fi

  log "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
print_status
echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
