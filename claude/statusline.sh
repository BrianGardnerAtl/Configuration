#!/bin/bash
# Claude Code status line
# Displays: color-coded context bar | model name | git branch / worktree

INPUT=$(cat)

# --- Parse JSON ---
MODEL=$(echo "$INPUT"   | jq -r '.model.display_name // "claude"')
PCT=$(echo "$INPUT"     | jq -r '.context_window.used_percentage // 0' | awk '{printf "%d", $1}')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.workspace.project_dir // .workspace.current_dir // ""')
WORKTREE_BRANCH=$(echo "$INPUT" | jq -r '.worktree.branch // ""')
WORKTREE_NAME=$(echo "$INPUT"   | jq -r '.worktree.name // ""')

# --- Git / worktree info ---
if [[ -n "$WORKTREE_BRANCH" ]]; then
    # Inside a worktree
    if [[ -n "$WORKTREE_NAME" ]]; then
        GIT_INFO="⎇ $WORKTREE_BRANCH  ($WORKTREE_NAME)"
    else
        GIT_INFO="⎇ $WORKTREE_BRANCH"
    fi
elif [[ -n "$PROJECT_DIR" ]]; then
    BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)
    if [[ -n "$BRANCH" ]]; then
        GIT_INFO="⎇ $BRANCH"
    else
        GIT_INFO=""
    fi
else
    GIT_INFO=""
fi

# --- Context bar (10 blocks) ---
FILLED=$(( PCT / 10 ))
EMPTY=$(( 10 - FILLED ))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="▓"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# --- Color: green < 70%, yellow 70–89%, red 90%+ ---
if   [[ $PCT -lt 70 ]]; then COLOR="\033[32m"
elif [[ $PCT -lt 90 ]]; then COLOR="\033[33m"
else                          COLOR="\033[31m"
fi
RESET="\033[0m"

# --- Assemble output ---
LINE="${COLOR}${BAR}${RESET} ${PCT}%  ${MODEL}"
[[ -n "$GIT_INFO" ]] && LINE+="  ${GIT_INFO}"

echo -e "$LINE"
