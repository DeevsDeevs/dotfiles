# Global Agent Guidance

## Working agreements
- Ask clarifying questions before non-trivial changes or assumptions.
- For larger tasks, propose a short plan and wait for confirmation before editing.
- Prefer pragmatic, minimal solutions; avoid over-engineering (YAGNI/KISS).
- Keep responses concise and action-focused.
- Ask for confirmation before adding new production dependencies.

## hc and chains
- You run inside hc (`$HC_TERMINAL_ID`). For long-running work, other machines or other agents, load the `hc` skill.
- Never detach processes with `&`, `nohup`, `disown`, or `setsid`.
- Save and resume work context with the `chains` skill.

## Tooling
- Prefer `rg` for searching the repo.

## Code quality
- Code should be self-explanatory; comment only when the reasoning is non-obvious.
- Favor descriptive naming and straightforward structure.
- Avoid unrelated refactors in the same change.

## Git workflow
- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- Branch prefixes: `feature/`, `fix/`, `refactor/`.

## Testing
- Don't add or run tests unless requested. If tests seem necessary, ask which ones to run.

## Review focus
- Prioritize correctness risks, regressions, and missing tests.

## Commits

Never add AI attribution to commits or PRs: no `Co-Authored-By: Claude`, no session links, no "Generated with" footers. The author is the user alone.
{{ template "server-context" . }}