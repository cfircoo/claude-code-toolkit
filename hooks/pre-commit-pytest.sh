#!/bin/bash
# Pre-commit/push hook: Run pytest for Python projects
# Blocks commit/push if tests fail, asking user what to do

set -e

# Read input JSON from stdin
INPUT=$(cat)

# Extract tool and operation info
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
SUBAGENT=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // ""')
SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // ""')
PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // ""' | tr '[:upper:]' '[:lower:]')
ARGS=$(echo "$INPUT" | jq -r '.tool_input.args // ""' | tr '[:upper:]' '[:lower:]')

# Check if this is a git commit/push/ship operation
IS_GIT_OP=false

# Check Task tool with git-ops subagent
if [[ "$TOOL" == "Task" && "$SUBAGENT" == "git-ops" ]]; then
    if echo "$PROMPT" | grep -qiE "(commit|push|ship)"; then
        IS_GIT_OP=true
    fi
fi

# Check Skill tool with git skill
if [[ "$TOOL" == "Skill" && "$SKILL" == "git" ]]; then
    if echo "$ARGS" | grep -qiE "(commit|push|ship)"; then
        IS_GIT_OP=true
    fi
fi

# If not a git operation we care about, approve
if [[ "$IS_GIT_OP" != "true" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check if this is a Python project
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
IS_PYTHON=false

if [[ -f "$PROJECT_DIR/pyproject.toml" ]] || \
   [[ -f "$PROJECT_DIR/setup.py" ]] || \
   [[ -f "$PROJECT_DIR/setup.cfg" ]] || \
   [[ -f "$PROJECT_DIR/requirements.txt" ]] || \
   [[ -d "$PROJECT_DIR/tests" && -n "$(find "$PROJECT_DIR/tests" -name '*.py' 2>/dev/null | head -1)" ]]; then
    IS_PYTHON=true
fi

# If not a Python project, approve
if [[ "$IS_PYTHON" != "true" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Run pytest
cd "$PROJECT_DIR"

# Check if pytest is available
if ! command -v pytest &> /dev/null; then
    # Try with python -m pytest
    if python -m pytest --version &> /dev/null 2>&1; then
        PYTEST_CMD="python -m pytest"
    else
        # No pytest available, approve and let it go
        echo '{"decision": "approve", "reason": "pytest not available, skipping tests"}'
        exit 0
    fi
else
    PYTEST_CMD="pytest"
fi

# Run tests and capture output
TEST_OUTPUT=$($PYTEST_CMD --tb=short -q 2>&1) || TEST_EXIT_CODE=$?
TEST_EXIT_CODE=${TEST_EXIT_CODE:-0}

if [[ $TEST_EXIT_CODE -eq 0 ]]; then
    # Tests passed
    echo '{"decision": "approve", "reason": "All tests passed"}'
else
    # Tests failed - block and include failure info
    # Escape the output for JSON
    ESCAPED_OUTPUT=$(echo "$TEST_OUTPUT" | jq -Rs '.')

    cat <<EOF
{
    "decision": "block",
    "reason": "Tests failed. Please ask the user how to proceed:\n\n${TEST_OUTPUT}\n\nOptions:\n1. Fix the failing tests first\n2. Proceed anyway (skip tests)\n3. Cancel the operation"
}
EOF
fi
