# run-to-completion

Goal: provide a CLI runner that keeps invoking Claude Code until a long-running goal reaches a terminal state.

## Design

`run-to-completion` is no longer a Codex/Claude skill. It is an outer control loop.

1. User runs `run-to-completion "<goal>"`.
2. Runner invokes `claude -p` once with the goal and current state.
3. Claude works inside the target repository.
4. Claude writes `.run-to-completion/status.json`.
5. Runner reads `status.json`.
6. Runner stops on `complete`, `blocked`, `unsafe`, or `impossible`.
7. Runner invokes Claude again on `continue`.

## State Files

- `.run-to-completion/status.json`: machine-readable runner status.
- `.run-to-completion/progress.md`: human-readable progress dashboard.
- `.run-to-completion/log.md`: concise work log maintained by Claude.
- `.run-to-completion/iteration-N.out`: stdout from each Claude invocation.
- `.run-to-completion/session-id`: Claude session UUID reused across iterations.

## Status Values

- `continue`: more allowed work remains.
- `complete`: success criteria are satisfied and verified.
- `blocked`: progress requires a user decision, secret, paid service, production access, or destructive action not already authorized.
- `unsafe`: continuing would create unacceptable risk.
- `impossible`: evidence shows the goal cannot be achieved with available tools/data.

## Success Criteria

- Installer creates a `run-to-completion` command.
- Runner can loop over `claude -p`.
- Runner stops only on terminal statuses or max iterations.
- Progress remains inspectable while the runner is active.
