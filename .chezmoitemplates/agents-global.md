# Global Agent Guidance

## Working agreements
- Ask clarifying questions before non-trivial changes or assumptions.
- For larger tasks, propose a short plan and wait for confirmation before editing.
- Prefer pragmatic, minimal solutions; avoid over-engineering (YAGNI/KISS).
- Keep responses concise and action-focused.
- Ask for confirmation before adding new production dependencies.

## Processes and background work
- Persistent or interactive processes — dev servers, watchers, REPLs, terminal panes, anything that must survive the agent session — belong in Herdr (`herdr`, https://herdr.dev), the detachable agent multiplexer; its socket API lets agents spawn panes, read output, and wait on each other.
- Never detach processes with `&`, `nohup`, `disown`, or `setsid`.
- Bounded non-interactive commands may use the session's own background/job facilities.

## Tooling
- For library-specific questions, use Context7 documentation when the tool is available.
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
