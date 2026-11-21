#!/bin/sh
# Skills for Claude Code, Codex, pi and Antigravity CLI (agy) from github.com/DeevsDeevs/agent-system.
# Reruns when this file changes; `npx skills update -g` pulls newer commits in between.
set -eu
command -v npx >/dev/null || { echo "npx not found: skipping agent skills" >&2; exit 0; }
# The clone ignores the user's git config: a rule there that turns https into ssh times out where
# port 22 is closed, and a public repo needs no key.
GIT_CONFIG_GLOBAL=/dev/null npx --yes skills add DeevsDeevs/agent-system --global \
  --agent claude-code codex pi antigravity-cli --skill '*' --yes
