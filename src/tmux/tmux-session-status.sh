#!/usr/bin/env bash
set -euo pipefail

current_session="${1:-}"

if ! command -v tmux >/dev/null 2>&1; then
  exit 0
fi

# Print numbered sessions for the status bar.
# Keep every segment style self-contained so alert colors do not "leak" and break the bar.
# pi's tmux extension also drops a marker file here because a terminal-native
# Ghostty/OSC notification bypasses tmux and therefore does not set #{session_alerts}.
notify_dir="${TMUX_AGENT_NOTIFY_DIR:-/tmp/tmux-agent-done}"

# Visiting a session acknowledges our file-based agent alert, matching tmux's
# native bell-alert behaviour.
if [[ -n "$current_session" && -e "$notify_dir/$current_session" ]]; then
  rm -f -- "$notify_dir/$current_session"
fi

base='#[fg=#abb2bf,bg=#1f2329,nobold,noitalics,nounderscore]'
active='#[fg=#1f2329,bg=#d19a66,bold]'
alert='#[fg=#1f2329,bg=#e06c75,bold]'
index=0

while IFS='|' read -r session alerts; do
  # Hidden popup sessions (e.g. spotify) stay out of the status bar.
  [[ "$session" == "spotify" ]] && continue

  index=$((index + 1))
  key="$index"
  if [[ "$index" -eq 10 ]]; then
    key=0
  fi

  label="$key:$session"
  if [[ "$session" == "$current_session" ]]; then
    printf '%s %s ' "$active" "$label"
  elif [[ -n "$alerts" || -e "$notify_dir/$session" ]]; then
    printf '%s %s ' "$alert" "$label"
  else
    printf '%s %s ' "$base" "$label"
  fi

  printf '%s ' "$base"
done < <(tmux list-sessions -F '#{session_name}|#{session_alerts}' 2>/dev/null)
