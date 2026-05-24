#!/usr/bin/env bash
# macOS system defaults for a fresh machine.
# Edit the variables below, then run: ./scripts/macos-defaults.sh
# Some commands need sudo - you will be prompted.

set -euo pipefail

# --- System naming (edit before running) ---
COMPUTER_NAME="Mika's MacBook Pro M5"
SHORT_NAME="m5"

# --- Apply ---
echo "→ Setting computer name + hostname to '$SHORT_NAME'..."
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$SHORT_NAME"
sudo scutil --set LocalHostName "$SHORT_NAME"
dscacheutil -flushcache

echo "→ Setting keyboard repeat (fast)..."
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo "✓ Done. Open a new terminal for the hostname change; logout/login (or restart apps) for key repeat."
