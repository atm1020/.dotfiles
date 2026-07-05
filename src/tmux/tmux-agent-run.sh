#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -lt 2 ]]; then
  echo "usage: $0 <agent-name> <command> [args...]" >&2
  exit 2
fi

agent_name="$1"
shift
notify_dir="${TMUX_AGENT_NOTIFY_DIR:-/tmp/tmux-agent-done}"
session_name="$(tmux display-message -p '#S' 2>/dev/null || true)"

# Run the interactive agent. Temporarily disable errexit so we can still mark
# completion and preserve the agent exit code.
set +e
"$@"
exit_code=$?
set -e

if [[ -n "$session_name" ]]; then
  mkdir -p "$notify_dir"
  printf '%s' "$agent_name" > "$notify_dir/$session_name"
  tmux refresh-client -S 2>/dev/null || true
fi

# BEL goes through the pane, so tmux sees it before Ghostty does.
printf '\a'
exit "$exit_code"
