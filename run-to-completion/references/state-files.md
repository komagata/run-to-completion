# State Files

Keep state concise and factual. These files are the handoff mechanism for long-running work, context compaction, restart recovery, and user-visible progress.

## `.run-to-completion/state.md`

Use this shape:

```markdown
# Run To Completion State

Goal:

Success criteria:

Progress summary:

Phase plan:

Active phase:

Completed phases:

Remaining phases:

Remaining estimate:

Estimate confidence:

Iteration loop:

Stop conditions:

Current milestone:

Completed:

Blocked:

Assumptions:

Verification status:

Final response gate:

Stop reason:

Next action:

Resume command/context:
```

Guidelines:

- Keep `Next action` executable by a fresh agent without reading the full conversation.
- Keep `Verification status` tied to concrete commands, tests, files, or source checks.
- Keep `Final response gate` set to `continue`, `complete`, `blocked`, `unsafe`, `impossible`, or `paused-by-platform-limit`.
- Keep `Stop reason` empty or `none` while `Final response gate` is `continue`. If the agent stops, write the concrete reason that made stopping valid.
- Keep `Progress summary` short enough for a user to scan during a status check.
- Write `Phase plan` as a checklist with phase states: `pending`, `active`, `blocked`, `done`, or `dropped`.
- Write `Remaining estimate` as a range of iterations, hours, tasks, or unknown; include why it changed when updating it.
- Move stale details into `log.md`; keep `state.md` current.

## `.run-to-completion/log.md`

Append entries in reverse chronological or chronological order, but stay consistent:

```markdown
## 2026-04-29 12:00 JST

Milestone:
Progress:
Estimate:
Actions:
Verification:
Decision:
Next:
```

Guidelines:

- Log failed attempts as well as successes.
- Include command names and important results, not full noisy output.
- Record estimate changes and the evidence behind them.
- Record why the loop changed direction.
- Do not store secrets, credentials, private tokens, or unnecessary sensitive data.

## `.run-to-completion/progress.md`

This is the human-facing dashboard. Keep it short and overwrite it with the latest status:

```markdown
# Run To Completion Progress

Status: running | blocked | paused | complete | unsafe | impossible
Updated: 2026-04-29 12:00 JST

Goal:

Now:

Overall progress:
- [done] ...
- [active] ...
- [pending] ...

Completed:

Remaining:

Estimate:

Confidence:

Current command/check:

Blocker:

Final response gate:

Next visible update:
```

Guidelines:

- Keep it under about 80 lines.
- Use plain language for humans, not only implementation notes.
- Update `Updated` every time the file changes.
- Set `Current command/check` before starting a long command so users can see what is happening while the agent is busy.
- Set `Final response gate` to `continue` unless a real stop condition has been reached.
- Use `Next visible update` to say when the dashboard is expected to change, such as `after go test ./... finishes` or `after the next benchmark run`.
