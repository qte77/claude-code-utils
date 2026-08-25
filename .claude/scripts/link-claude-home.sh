#!/usr/bin/env bash
set -euo pipefail
# Copyable snippet — NOT invoked by this plugin's own hooks.
#
# A Claude Code plugin hook (e.g. SessionStart) can only fire once Claude Code
# itself is already running with the plugin installed, which requires
# ~/.claude to already exist and be linked. That makes a hook structurally
# unable to bootstrap ~/.claude from scratch after it's wiped — the fix has
# to run before Claude Code's first launch in a fresh container.
#
# Copy this file into your repo (e.g. scripts/link-claude-home.sh) and call
# it first in your .devcontainer/devcontainer.json's onCreateCommand, before
# any step that installs or touches Claude Code:
#   "onCreateCommand": "bash scripts/link-claude-home.sh && <rest of setup>"
#
# Symlinks $HOME/.claude to a directory that survives container rebuilds
# (e.g. /workspaces on GitHub Codespaces — everything outside /workspaces is
# cleared on rebuild, everything inside it persists). Idempotent: seeds the
# persisted directory from an existing ~/.claude on first run, re-links on
# every later run.
#
# Override paths with CLAUDE_HOME_DIR / CLAUDE_HOME_PERSIST_DIR if your
# platform's persisted mount isn't /workspaces.

home="${CLAUDE_HOME_DIR:-$HOME/.claude}"
target="${CLAUDE_HOME_PERSIST_DIR:-/workspaces/.claude-files}"

if [ -L "$home" ]; then
  echo "[link-claude-home] already linked: $home -> $(readlink "$home")"
  exit 0
fi

if [ -e "$target" ]; then
  rm -rf "$home"
else
  mv "$home" "$target" 2>/dev/null || mkdir -p "$target"
fi

ln -s "$target" "$home"
echo "[link-claude-home] linked $home -> $target"
