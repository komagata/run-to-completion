---
name: run-to-completion
description: Use when the user gives a clear long-running goal and wants the agent to keep working without repeated human check-ins until the goal is complete, unsafe, or impossible. Supports autonomous multi-iteration coding, research, optimization, flaky-test cleanup, implementation milestones, overnight work, resumable progress after context/token limits, and argument-free invocation that first elicits the goal, iteration loop, and stop conditions.
---

# Run To Completion

Use this skill to pursue a well-defined goal across many iterations with minimal user interruption.

The agent must keep a durable state file so work can continue after context compaction, process restart, or token-limit pause. The skill cannot override model or product limits by itself; it makes continuation reliable by recording enough state for the next session to resume.

## Argument-Free Invocation

If the user invokes this skill without a concrete goal, ask only the missing questions needed to start:

1. What is the goal?
2. What iteration loop should I repeat? If omitted, use `inspect -> act -> verify -> record`.
3. What stop conditions should I obey? If omitted, stop only when the goal is complete, impossible, unsafe, or likely to cause significant cost/damage.

Confirm the interpreted goal, loop, and stop conditions in concise terms before starting.

## Start Protocol

Before doing substantial work:

1. Restate assumptions.
2. Define verifiable success criteria.
3. Create or update `.run-to-completion/state.md`.
4. Create or update `.run-to-completion/log.md`.
5. Choose the next smallest milestone that moves directly toward the goal.

Use [references/state-files.md](references/state-files.md) for the required file shapes.

## Execution Loop

Repeat until a stop condition is reached:

1. Inspect: gather only the context needed for the next milestone.
2. Plan: write a short milestone plan with its verification command or evidence.
3. Act: make the smallest useful change or perform the next research step.
4. Verify: run focused tests, commands, checks, or source validation.
5. Record: update `.run-to-completion/state.md` and append `.run-to-completion/log.md`.
6. Decide: continue, revise the approach, or stop with a clear reason.

Prefer focused verification first. Broaden verification when the change affects shared behavior, public interfaces, or user-visible workflows.

## Autonomy Rules

- Do not ask the user routine implementation questions; make conservative assumptions and record them.
- Do ask or stop when continuing would be unsafe, destructive, legally risky, financially risky, or impossible without secrets/credentials the user has not provided.
- Do not invent success. If verification fails, record the failure and either fix it or choose a smaller next milestone.
- Do not chase unrelated cleanup. Keep each iteration tied to the stated goal.
- Do not run destructive commands unless the user explicitly allowed them or they are clearly inside a disposable sandbox.

## Token-Limit And Resume Behavior

When context, token, or time limits are approaching:

1. Stop starting new work.
2. Finish or revert only the current incomplete local edit if needed to leave files coherent.
3. Update `.run-to-completion/state.md` with the exact next action.
4. Append the latest verification status to `.run-to-completion/log.md`.
5. End with a short resume instruction.

On resume, read `.run-to-completion/state.md` first, then the end of `.run-to-completion/log.md`, then continue from `Next action`.

For Codex, rely on the platform's compaction/resume behavior plus the state files. For Claude Code, rely on its session continuation or a new session that reads the same skill and state files. This skill must not claim it can bypass provider context limits.

## Stop Conditions

Stop and report when any of these is true:

- Success criteria are satisfied and verified.
- The goal is impossible under the available tools, permissions, data, or time.
- Further progress requires a user decision, secret, paid service, production access, or destructive action not already authorized.
- Continuing is likely to cause significant security, privacy, legal, financial, or operational harm.
- Repeated iterations produce no new information or measurable progress; record what was tried and what evidence blocks progress.

## Completion Report

When stopping, report:

- Final status: complete, blocked, unsafe, or impossible.
- Evidence: tests, commands, artifacts, links, or data that support the status.
- Changed files or produced artifacts.
- Remaining risks or next action, if any.
