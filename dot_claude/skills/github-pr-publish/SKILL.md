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

## Step 1 — Confirm the working branch

Run:
```bash
git branch --show-current
```

Show the user the current branch name and ask: **"Is this the branch you want to publish as a PR?"**

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

## Step 3 — Push the branch

Run:
```bash
git push --set-upstream origin <current-branch>
```

Capture stdout/stderr. If the push fails, surface the error to the user and stop.

---

## Step 4 — Fetch context for the PR description

### 4a — Read the Jira ticket

Use `Atlassian:getJiraIssue` with `cloudId: "canva.atlassian.net"` and the provided `jira_ticket_id`. Extract:
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
- Changes section should be precise and technical — name functions, components, endpoints, configs that changed.
- Action items coverage is the most important section: make the mapping explicit so reviewers understand the PR scope.
- Do not pad with filler. If something is unknown, use a TODO placeholder rather than guessing.

---

## Step 6 — Create the PR via GitHub CLI

Run:
```bash
gh pr create \
  --base <target_branch> \
  --title "<Jira ticket summary>" \
  --body "<PR description from Step 5>"
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
