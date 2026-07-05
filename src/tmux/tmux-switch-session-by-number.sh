#!/usr/bin/env bash
set -euo pipefail

slot="${1:-}"

if [[ -z "$slot" || ! "$slot" =~ ^[0-9]+$ ]]; then
  tmux display-message "Invalid session slot: ${slot:-empty}"
  exit 0
fi

target=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | sed -n "${slot}p")

if [[ -z "$target" ]]; then
  tmux display-message "No tmux session at slot $slot"
  exit 0
fi

tmux switch-client -t "$target"
