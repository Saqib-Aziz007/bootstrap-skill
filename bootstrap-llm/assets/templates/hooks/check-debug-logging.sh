#!/bin/bash
# Flag debug logging in changed source files; production paths use the project logger.
# PostToolUse (Edit|Write); receives tool JSON on stdin. FULL depth only.
# Generator: fill the debug pattern for the stack (e.g. 'console\.(log|debug)' or '(^|[^.[:alnum:]_])print\(')
# and the logger pointer; extend the test-path filter to match the project's test layout.

input=$(cat)
file=$(printf '%s' "$input" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

case "$file" in
  {{SOURCE_EXT_CASE_PATTERN}}) ;;
  *) exit 0 ;;
esac
case "$file" in
  *test*|*spec*|*__tests__*|*e2e*) exit 0 ;;
esac

[ -f "$file" ] || exit 0
hits=$(grep -nE '{{DEBUG_PATTERN}}' "$file" | head -5)
if [ -n "$hits" ]; then
  echo "Debug logging in $file; use {{LOGGER_POINTER}} instead:" >&2
  printf '%s\n' "$hits" >&2
  exit 2
fi
exit 0
