#!/bin/bash
# shell — statusline badge script for Gemini CLI, Claude Code, and Codex
# Reads the shell mode flag file and outputs a colored badge.

if [ -n "$GEMINI_CONFIG_DIR" ]; then
  ECO_DIR="$GEMINI_CONFIG_DIR"
elif [ -n "$CLAUDE_CONFIG_DIR" ]; then
  ECO_DIR="$CLAUDE_CONFIG_DIR"
elif [ -n "$CODEX_CONFIG_DIR" ]; then
  ECO_DIR="$CODEX_CONFIG_DIR"
elif [ -d "$HOME/.gemini" ]; then
  ECO_DIR="$HOME/.gemini"
elif [ -d "$HOME/.claude" ]; then
  ECO_DIR="$HOME/.claude"
elif [ -d "$HOME/.codex" ]; then
  ECO_DIR="$HOME/.codex"
else
  exit 0
fi

FLAG="$ECO_DIR/.shell-active"

# Refuse symlinks
[ -L "$FLAG" ] && exit 0
[ ! -f "$FLAG" ] && exit 0

# Hard-cap the read at 64 bytes
MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
MODE=$(printf '%s' "$MODE" | tr -cd 'a-z0-9-')

# Whitelist
case "$MODE" in
  off|verbose|strict|axiomatic|soap|commit|review|compress) ;;
  *) exit 0 ;;
esac

if [ -z "$MODE" ] || [ "$MODE" = "strict" ]; then
  printf '\033[38;5;172m[S.H.E.L.L.]\033[0m'
else
  SUFFIX=$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')
  printf '\033[38;5;172m[S.H.E.L.L.:%s]\033[0m' "$SUFFIX"
fi
