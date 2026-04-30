# run-to-completion

`run-to-completion` is a CLI runner for long-running Claude Code work.

Instead of relying on a skill or slash command to keep one agent session alive, it runs `claude -p` as a repeatable one-shot command. After every invocation, Claude writes `.run-to-completion/status.json`. The runner reads that file and starts another invocation while the status is `continue`.

This makes the outer loop deterministic:

```text
run-to-completion
  -> claude -p
  -> read .run-to-completion/status.json
  -> continue | complete | blocked | unsafe | impossible
```

## Why This Exists

Interactive agents can stop before the goal is done because the model thinks a milestone is a natural handoff, the session ends, or context pressure changes behavior. This runner moves continuation control outside the model.

The model still decides what work to do next, but the runner decides whether another Claude invocation should happen.

## Install Or Update

```bash
curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash
```

The installer clones or updates this repository under `~/.local/share/run-to-completion/repo` and symlinks:

```text
~/.local/bin/run-to-completion -> ~/.local/share/run-to-completion/repo/bin/run-to-completion
```

If `run-to-completion` is not found after install, add `~/.local/bin` to your `PATH`.

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Run it from the target repository:

```bash
run-to-completion "Fix flaky tests and verify the full test suite passes"
```

Useful options:

```bash
run-to-completion --max-iterations 20 "Improve benchmark runtime below 200ms"
run-to-completion --retry-delay 1800 --max-rate-limit-retries 12 "Run the overnight cleanup"
run-to-completion --model opus "Implement the parser described in SPEC.md"
run-to-completion --permission-mode acceptEdits "Refactor the CLI and update tests"
run-to-completion --workdir /path/to/project "Ship the requested feature"
```

Defaults:

- `--max-iterations 100`
- `--claude-bin claude`
- `--permission-mode auto`
- `--retry-delay 3600`
- `--max-rate-limit-retries 24`
- `--workdir .`

Environment overrides:

- `RUN_TO_COMPLETION_MAX_ITERATIONS`
- `RUN_TO_COMPLETION_CLAUDE_BIN`
- `RUN_TO_COMPLETION_MODEL`
- `RUN_TO_COMPLETION_PERMISSION_MODE`
- `RUN_TO_COMPLETION_RETRY_DELAY`
- `RUN_TO_COMPLETION_MAX_RATE_LIMIT_RETRIES`
- `RUN_TO_COMPLETION_BIN_DIR`
- `RUN_TO_COMPLETION_HOME`

## Status Contract

Claude must write valid JSON to:

```text
.run-to-completion/status.json
```

Shape:

```json
{
  "status": "continue",
  "summary": "Short factual summary.",
  "next_action": "Next action if status is continue.",
  "evidence": ["commands, files, tests, or facts supporting the status"],
  "updated_at": "2026-04-30T00:00:00Z"
}
```

Allowed statuses:

- `continue`: more allowed work remains; the runner starts Claude again.
- `rate_limited`: Claude reported an explicit rate-limit or usage-limit error; the runner waits and retries.
- `complete`: success criteria are satisfied and verified.
- `blocked`: progress requires a user decision, secret, paid service, production access, or destructive action not already authorized.
- `unsafe`: continuing would create security, privacy, legal, financial, or operational risk.
- `impossible`: evidence shows the goal cannot be achieved with available tools/data.

A failed test, known TODO, or known next action is not `blocked`. Claude should fix it or set `continue`.

The runner does not infer rate limits from vague failures. It writes `rate_limited` only when Claude output contains an explicit signal documented by Claude Code or the Claude API, such as `You've hit your session limit`, `You've hit your weekly limit`, `API Error: Server is temporarily limiting requests`, `API Error: Request rejected (429)`, or API JSON with `error.type == "rate_limit_error"`.

## Progress Files

The runner and Claude use:

```text
.run-to-completion/status.json
.run-to-completion/progress.md
.run-to-completion/log.md
.run-to-completion/iteration-N.out
.run-to-completion/session-id
```

`progress.md` is the human-facing dashboard. You can watch it from another terminal:

```bash
watch -n 5 'sed -n "1,120p" .run-to-completion/progress.md'
```

`iteration-N.out` stores each Claude invocation output.

## Update

Run the installer again:

```bash
curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash
```

## Development

Static checks:

```bash
bash -n install.sh
bash -n bin/run-to-completion
```
