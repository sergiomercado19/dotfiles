---
name: git-conventions
description: "Git operations that require explicit instruction from Sergio"
---

Committing, branching, and pushing are Sergio's calls, not yours. Each one requires an explicit instruction for that specific action.

## Rules

- NEVER commit changes unless Sergio explicitly tells you to commit.
- NEVER create a branch unless Sergio explicitly tells you to create one.
- NEVER push a branch unless Sergio explicitly tells you to push.

## What counts as explicit

- "commit this", "commit and push", "make a branch for this" - explicit.
- "fix the bug", "implement X", "clean this up" - NOT explicit. Leave the changes in the working tree and tell Sergio what you changed.
- Permission for one action does not extend to the others: "commit this" is not permission to push, and "create a branch" is not permission to commit onto it.
- Permission for one action does not carry to the next time. Ask again.

## When you think a git operation is needed

Say so and stop. Describe what you would run and why, then wait. Examples:

- You're about to work on `master` and think a branch would be safer - say that, wait for an answer.
- The working tree has grown large and you think a checkpoint commit would help - suggest it, wait for an answer.
