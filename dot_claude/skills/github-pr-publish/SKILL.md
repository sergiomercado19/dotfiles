---
name: github-pr-publish
description: Publishes a GitHub Pull Request for the current branch and writes a PR description grounded in the related Jira ticket and the actual git diff. Use this skill whenever the user asks to "publish a PR", "push a PR", "open a pull request", "create a PR", "raise a PR", or "submit a PR". Requires a Jira ticket ID as input. Optionally accepts a target branch (defaults to master).
argument-hint: "[jira_ticket_id] [target_branch?]"
---

# GitHub – PR Publish

Pushes the current branch to GitHub, then writes and opens a Pull Request whose description is grounded in both the Jira ticket and the actual diff introduced by the branch.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `jira_ticket_id` | ✅ | — | e.g. `EXS-123` |
| `target_branch` | ❌ | `master` | Branch the PR merges into |

---

## Step 1 — Confirm the working branch and target

Run:
```bash
git branch --show-current
```

Show the user the current branch name and the target branch (from input, or `master` if not provided), then ask:

**"Is this the branch you want to publish as a PR, merging into `<target_branch>`?"**

Do not proceed until confirmed.

---

## Step 2 — Check for uncommitted changes

Run:
```bash
git status --short
```

If there is any output (staged, unstaged, or untracked files), **stop and tell the user**:

> "There are uncommitted changes in the working directory. Please stage and commit (or stash) them before publishing the PR."

List the dirty files so the user can act on them. Do not proceed until the working tree is clean or the user confirms they want to continue.

---

## Step 3 — Push the branch and fetch context (run in parallel)

Steps 3 and 4 are independent — run them at the same time.

### 3a — Push the branch

Run:
```bash
git push
```

Capture stdout/stderr. If the error output instructs you to set an upstream (e.g. "set the remote as upstream" / "use --set-upstream"), re-run:
```bash
git push --set-upstream origin <current-branch>
```

If the push fails for any other reason, surface the error to the user and stop.

---

## Step 4 — Fetch context for the PR description

### 4a — Read the Jira ticket

Run:
```bash
otter mcp exec --no-confirm jira_get_issue --issue_key="<jira_ticket_id>"
```

Extract:
- **Summary** (ticket title)
- **Description** — specifically the background/context paragraph and the `### 🚀 Action Items` list

### 4b — Get the git diff summary

Run:
```bash
git log origin/<target_branch>..HEAD --oneline
```
to get commit history, then:

```bash
git diff origin/<target_branch>...HEAD --stat
```
for a file-level summary, then:

```bash
git diff origin/<target_branch>...HEAD
```
for the full diff. If the full diff is very large (>500 lines), use `--stat` plus per-file diffs for the most significant changed files only.

---

## Step 5 — Write the PR description

Compose a PR description using this template: `templates/pr-description.tmpl`. Fill in the sections with the Jira ticket context and action items, and the summary of changes from the git diff.

**Guidelines for writing the description:**
- Changes section should be brief and only reserved for complex technical changes not obvious to the reviewer. It's okay to omit this section if everything is simple.
- Do not pad with filler. If something is unknown, use a TODO placeholder rather than guessing.
- Do not come up with potentially redundant info via negation of available context, only glean actually differentiated useful lines for the audience.
- Only include the Before/After table if there are Frontend changes (typically, TypeScript or Storybook files)

---

## Step 6 — Create the PR via GitHub CLI

### 6a — Derive the PR title

Build the title from the branch name, not just the Jira ticket summary:

1. Extract the Jira ticket ID: `[EXS-1085]`
2. Look for a scope/product label in the branch name (e.g. `quickflight` → `QuickFlight`, `payments` → `Payments`). Title-case it.
3. Compose a short human-readable description from the remainder of the branch name, cross-referenced with the Jira ticket summary.

Format: `[JIRA-ID] ScopeLabel - Description`
Example: `[EXS-1085] QuickFlight - Add governance manifest to QuickPage`

If no scope label is identifiable from the branch name, fall back to `[JIRA-ID] Description`.

### 6b — Run `gh pr create`

Run:
```bash
gh pr create \
  --base <target_branch> \
  --title "<title from 6a>" \
  --body "<PR description from Step 5>" \
  --assignee sergiomercado19
```

If `gh` is not installed or the user is not authenticated, output the PR description as a code block and instruct the user to paste it manually when creating the PR on GitHub.

Capture the PR URL from stdout.

---

## Step 7 — Return the PR link

Return the PR URL to the user:

> "PR published: https://github.com/..."

Optionally show the PR description that was written so the user can review or copy it.

---

## Error Handling

| Situation | Action |
|---|---|
| Dirty working tree | Stop at Step 2, list the files, ask user to commit/stash or confirm they want to continue |
| Push rejected (e.g. force push needed) | Surface the git error verbatim, stop |
| `gh` CLI not found | Output description as a copyable block, link to GitHub to create PR manually |
| Jira ticket not found | Warn the user; offer to proceed with description based on diff only |
| Diff is empty (branch is identical to target) | Warn the user before creating an empty PR |
