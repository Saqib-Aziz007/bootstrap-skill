#!/bin/bash
# Fast static check after every edit, so type breakage never accumulates.
# PostToolUse (Edit|Write); receives tool JSON on stdin.
# Generator: fill the extension pattern and the fast check command for the stack;
# omit this hook entirely when the stack has no fast checker.

input=$(cat)
file=$(printf '%s' "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$file" in
  {{SOURCE_EXT_CASE_PATTERN}}) ;;
  *) exit 0 ;;
esac

cd "$CLAUDE_PROJECT_DIR" || exit 0
out=$({{TYPECHECK_FAST_CMD}} 2>&1)
status=$?
if [ $status -ne 0 ]; then
  echo "Static check failed after editing $file:" >&2
  printf '%s\n' "$out" | head -30 >&2
  exit 2
fi
exit 0
