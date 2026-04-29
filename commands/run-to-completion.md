---
description: Run a long task to completion with resumable progress tracking
argument-hint: [goal, iteration loop, stop conditions]
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit, WebFetch]
---

# run-to-completion

Use the bundled `run-to-completion` skill for this request.

The user invoked this entry point with:

```text
$ARGUMENTS
```

## Instructions

1. Read `run-to-completion/SKILL.md`.
2. Read `run-to-completion/references/state-files.md`.
3. Treat `$ARGUMENTS` as the initial goal and optional parameters.
4. If `$ARGUMENTS` does not contain a concrete goal, follow the skill's argument-free invocation flow and ask only for the missing goal, iteration loop, and stop conditions.
5. Start the run-to-completion workflow exactly as the skill describes.

Do not treat this entry point as a one-shot answer. It starts the long-running autonomous workflow.
