#!/bin/sh
# Skills for Claude Code, Codex, pi and Antigravity CLI (agy) from github.com/DeevsDeevs/agent-system.
# Reruns when this file changes; `npx skills update -g` pulls newer commits in between.
set -eu
command -v npx >/dev/null || { echo "npx not found: skipping agent skills" >&2; exit 0; }
npx --yes skills add DeevsDeevs/agent-system --global \
  --agent claude-code codex pi antigravity-cli --skill '*' --yes
