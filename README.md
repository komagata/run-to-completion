# run-to-completion

`run-to-completion` is an agent skill for long-running goals. It asks for a goal, optional iteration loop, and optional stop conditions, then keeps working until the goal is complete, unsafe, impossible, or blocked by a required user decision.

It is designed for tasks such as overnight coding work, research passes, performance improvement, flaky-test cleanup, and multi-step implementation projects.

## What It Does

- Elicits missing inputs when invoked without arguments.
- Defines success criteria before substantial work starts.
- Repeats an `inspect -> act -> verify -> record` loop by default.
- Records durable progress in `.run-to-completion/state.md` and `.run-to-completion/log.md`.
- Gives the next agent enough context to resume after context compaction, token limits, or a restarted session.
- Stops on safety, cost, destructive-action, or impossibility boundaries.

The skill does not bypass provider context limits or quota limits. It makes long work resumable by keeping concise state files.

## Repository Layout

```text
run-to-completion/
├── PLAN.md
└── run-to-completion/
    ├── CLAUDE.md
    ├── SKILL.md
    ├── agents/openai.yaml
    └── references/state-files.md
```

## Install For Codex

Copy or symlink the skill directory into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
ln -s "$(pwd)/run-to-completion" "${CODEX_HOME:-$HOME/.codex}/skills/run-to-completion"
```

Then ask Codex to use `run-to-completion` for a long-running goal.

Example:

```text
Use run-to-completion. Goal: reduce the benchmark runtime below 200ms.
Iteration loop: inspect bottleneck, implement one optimization, run benchmark, record.
Stop if the change would alter public behavior or require production credentials.
```

## Use With Claude Code

Claude Code can read the same instructions from `run-to-completion/CLAUDE.md`, which imports `SKILL.md`.

One simple approach is to copy or import the skill instructions into a project or user `CLAUDE.md`:

```markdown
@/absolute/path/to/run-to-completion/run-to-completion/CLAUDE.md
```

Then start Claude Code in the target project and ask it to use `run-to-completion` with a goal.

## Argument-Free Use

If invoked without a goal, the skill instructs the agent to ask:

1. What is the goal?
2. What iteration loop should I repeat?
3. What stop conditions should I obey?

If the user omits optional answers, the default loop is:

```text
inspect -> act -> verify -> record
```

Default stop conditions are completion, impossibility, safety risk, or significant cost/damage risk.

## Resume Files

During work, the agent creates files in the target project:

```text
.run-to-completion/state.md
.run-to-completion/log.md
```

On resume, the next agent should read `state.md` first, then the end of `log.md`, and continue from `Next action`.

## Development

Validate the skill format with:

```bash
python3 /home/komagata/.codex/skills/.system/skill-creator/scripts/quick_validate.py run-to-completion
```

The validation script checks the required skill metadata and naming rules.
