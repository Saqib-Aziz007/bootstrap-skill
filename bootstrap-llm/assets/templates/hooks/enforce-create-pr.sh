#!/bin/bash
# Route PR creation through /create-pr so description quality never depends on session mood.
# PreToolUse (Bash); receives tool JSON on stdin. /create-pr itself sets BYPASS_CREATE_PR_HOOK=1.

input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

case "$cmd" in
  *"gh pr create"*)
    case "$cmd" in
      *BYPASS_CREATE_PR_HOOK=1*) exit 0 ;;
    esac
    echo "Use the /create-pr skill instead of raw 'gh pr create': it extracts intent, validates the diff, and fills the PR template." >&2
    exit 2
    ;;
esac
exit 0
