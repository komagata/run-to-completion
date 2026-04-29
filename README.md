# run-to-completion

`run-to-completion` is an agent skill for long-running goals. It asks for a goal, optional iteration loop, and optional stop conditions, then keeps working until the goal is complete, unsafe, impossible, or blocked by a required user decision.

It is designed for tasks such as overnight coding work, research passes, performance improvement, flaky-test cleanup, and multi-step implementation projects.

## What It Does

- Elicits missing inputs when invoked without arguments.
- Defines success criteria before substantial work starts.
- Maintains a visible phase plan with active phase, completed work, remaining work, and estimate confidence.
- Repeats an `inspect -> act -> verify -> record` loop by default.
- Emits short progress updates when meaningful steps, milestones, phases, or verification checks complete.
- Records durable progress in `.run-to-completion/state.md`, `.run-to-completion/progress.md`, and `.run-to-completion/log.md`.
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

## Quick Install Or Update

Run the same command for first install and updates:

```bash
curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash
```

The installer clones or updates this repository under `~/.local/share/run-to-completion/repo`, then links the skill into `${CODEX_HOME:-~/.codex}/skills/run-to-completion`.

Then ask Codex to use `run-to-completion` for a long-running goal.

`run-to-completion` is a skill, not a slash command. Do not type `/run-to-completion`; Codex will report it as an unrecognized command. Use a normal prompt instead.

Example:

```text
Use run-to-completion. Goal: reduce the benchmark runtime below 200ms.
Iteration loop: inspect bottleneck, implement one optimization, run benchmark, record.
Stop if the change would alter public behavior or require production credentials.
```

## Manual Install For Codex

Copy or symlink the skill directory into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
ln -s "$(pwd)/run-to-completion" "${CODEX_HOME:-$HOME/.codex}/skills/run-to-completion"
```

Symlink installation is recommended because updates are just `git pull` in this repository.

After installing manually, use a normal prompt such as `Use run-to-completion. Goal: ...`; this skill is not started with `/run-to-completion`.

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
.run-to-completion/progress.md
.run-to-completion/log.md
```

On resume, the next agent should read `state.md` first, then the end of `log.md`, and continue from `Next action`.

## Live Progress

The agent writes `.run-to-completion/progress.md` as a short dashboard that can be watched while the agent is busy. Open it in an editor, or run:

```bash
watch -n 5 'sed -n "1,120p" .run-to-completion/progress.md'
```

The dashboard records:

- The whole phase plan.
- The active phase.
- Completed and remaining phases.
- The latest remaining-work estimate.
- The confidence and evidence behind that estimate.
- The current command or check, when a long command is running.

When you ask "where are we?" or "how much is left?", the agent should answer from `.run-to-completion/state.md` before continuing. When you cannot ask because the agent is busy, inspect `.run-to-completion/progress.md` directly.

In the conversation, the agent should also send a short update after each meaningful step or verification result. These updates should say what changed, where the task is now, and what comes next.

## Updating The Skill

If you used the quick install command, run it again:

```bash
curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash
```

If you installed manually by symlink from a cloned repository:

```bash
cd /path/to/run-to-completion
git pull
```

If you copied the directory instead of symlinking it, pull the repository and copy the skill directory again:

```bash
cd /path/to/run-to-completion
git pull
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/run-to-completion"
cp -R run-to-completion "${CODEX_HOME:-$HOME/.codex}/skills/run-to-completion"
```

For Claude Code, update the repository copy referenced by your `CLAUDE.md` import. If you copied the instructions into another `CLAUDE.md`, copy the new contents again.

## Development

Validate the skill format with:

```bash
python3 /home/komagata/.codex/skills/.system/skill-creator/scripts/quick_validate.py run-to-completion
```

The validation script checks the required skill metadata and naming rules.
