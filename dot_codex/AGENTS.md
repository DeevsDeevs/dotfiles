# Global Codex Guidance

## Working agreements
- Ask clarifying questions before non-trivial changes or assumptions.
- For larger tasks, propose a short plan and wait for confirmation before editing.
- Prefer pragmatic, minimal solutions; avoid over-engineering (YAGNI/KISS).
- Keep responses concise and action-focused.
- Ask for confirmation before adding new production dependencies.

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
- Don’t add or run tests unless requested. If tests seem necessary, ask which ones to run.

## Review focus
- Prioritize correctness risks, regressions, and missing tests.
