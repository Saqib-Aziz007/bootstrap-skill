#!/bin/bash
# Enforce the always-loaded context budget (see .claude/rules/llm-docs.md).
# PostToolUse (Edit|Write). Exit 2 feeds the message back to the session.
BUDGET_KB={{BUDGET_KB}}

cd "$CLAUDE_PROJECT_DIR" || exit 0
total_bytes=$(cat CLAUDE.md .claude/rules/*.md 2>/dev/null | wc -c | tr -d ' ')
total_kb=$(( ${total_bytes:-0} / 1024 ))

if [ "$total_kb" -gt "$BUDGET_KB" ]; then
  echo "Always-loaded docs (CLAUDE.md + .claude/rules) are ${total_kb}KB; budget is ${BUDGET_KB}KB." >&2
  echo "Move detail into llm/ or .claude/refs/ (loaded on demand); see .claude/rules/llm-docs.md." >&2
  exit 2
fi
exit 0
