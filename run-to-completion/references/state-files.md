# State Files

Keep state concise and factual. These files are the handoff mechanism for long-running work, context compaction, and restart recovery.

## `.run-to-completion/state.md`

Use this shape:

```markdown
# Run To Completion State

Goal:

Success criteria:

Iteration loop:

Stop conditions:

Current milestone:

Completed:

Blocked:

Assumptions:

Verification status:

Next action:

Resume command/context:
```

Guidelines:

- Keep `Next action` executable by a fresh agent without reading the full conversation.
- Keep `Verification status` tied to concrete commands, tests, files, or source checks.
- Move stale details into `log.md`; keep `state.md` current.

## `.run-to-completion/log.md`

Append entries in reverse chronological or chronological order, but stay consistent:

```markdown
## 2026-04-29 12:00 JST

Milestone:
Actions:
Verification:
Decision:
Next:
```

Guidelines:

- Log failed attempts as well as successes.
- Include command names and important results, not full noisy output.
- Record why the loop changed direction.
- Do not store secrets, credentials, private tokens, or unnecessary sensitive data.
