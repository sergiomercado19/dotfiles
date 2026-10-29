---
name: dotfiles-save-changes
description: Save changes made in ~ back to the personal chezmoi dotfiles repo. Finds files chezmoi tracks that were edited, added or removed in ~, asks which ones to keep with a multiple choice question, then runs `chezmoi add` / `re-add` / `forget`, commits and pushes. Use when Sergio asks to "save my dotfiles", "sync dotfile changes", "add this to my dotfiles", or "commit my dotfiles". Other chezmoi sources (such as a work source) can follow this procedure with their own values.
---

# Dotfiles – Save Changes

Find what changed in `~` for one chezmoi source, let Sergio pick what to keep,
then add it to the source, commit and push.

Selecting changes in the question is Sergio's instruction to add, commit and
push them. Never commit or push anything that wasn't selected.

## Values for this source

| Value | Personal source |
|---|---|
| `CZ` (chezmoi command) | `chezmoi` |
| `SRC` (source repo) | `~/.local/share/chezmoi` |
| Remote | `origin` |
| Watched dirs for new files | `~/.agents` |
| Owns | Generic config that makes sense on any machine |
| Other sources (`OTHER_CZ`) | `chezmoi --source ~/.local/share/chezmoi-work --config ~/.config/chezmoi-work/chezmoi.toml`, if `~/.local/share/chezmoi-work` exists |
| Public repo | Yes |

Another source following this skill substitutes its own values for this table
and keeps every step below. Shell aliases aren't available to the Bash tool, so
always spell out the full command.

## Step 1 – Check the source repo

```sh
git -C "$SRC" status --short
git -C "$SRC" fetch -q && git -C "$SRC" status -sb | head -1
```

- If the working tree isn't clean, stop and ask what to do with those changes.
- If the branch is behind its remote, stop and ask Sergio to pull and apply
  first. Re-adding files over a stale source would undo the incoming changes.

## Step 2 – Find the changes

### Changed or removed tracked files

Run `$CZ status`. Each line has two status columns before the target path:

| Column 1 | Column 2 | Meaning | Offer it? |
|---|---|---|---|
| `M` | ` ` or `M` | Edited in `~` since chezmoi last wrote it | Yes, as **modified** |
| `D` | any | Removed from `~` | Yes, as **removed** |
| ` ` | `A` | In the source but missing from `~` | Only if it was in `~` before (see below). Otherwise **no**: it was never applied, so list it under "not applied yet" |
| ` ` | `M` | The source is ahead of `~` (pulled or edited, not applied) | **No.** Re-adding would revert the source. List it under "not applied yet" in the summary |

`MM` means both sides changed: show the diff and warn that re-adding discards
the source's unapplied change.

For a missing target (` A`), check whether any chezmoi source on the machine
ever wrote it. A file can have been written by a different source than the one
that manages it now, e.g. after it moved between repos:

```sh
$CZ state get --bucket=entryState --key="$HOME/<target>"
$OTHER_CZ state get --bucket=entryState --key="$HOME/<target>"
```

If either prints an entry, the target was in `~` and has been removed: offer it
as **removed**. If neither does, it was never applied.

A source that has never been applied has no saved state, so column 1 is blank
for everything. Its local edits show as ` M`, so they aren't offered. Tell
Sergio to run `$CZ apply` once (after checking `$CZ diff`) so later runs can
tell the difference.

### New files

For each watched dir, list what no chezmoi source on the machine manages or
ignores:

```sh
comm -12 <($CZ unmanaged ~/.agents | sort) <($OTHER_CZ unmanaged ~/.agents | sort)
```

With no other source, use `$CZ unmanaged ~/.agents` alone. Ignored paths
(`.chezmoiignore`) are already excluded by `unmanaged`. Report symlinks into
another tool's directory as installed by that tool, and offer them only as
**ignore**.

### Renames

A removed directory and a new sibling with mostly the same files are a rename.
Present them as one **renamed** option (`old → new`).

## Step 3 – Decide which source each change belongs to

- Offer only changes this source owns (see **Owns** in the table).
- Changes that belong to another source: don't offer them here. List them in
  the summary and name that source's skill.
- **Public repo:** read the diff of every candidate. Anything employer-specific
  (company or product names, internal tools, hostnames, URLs, ticket projects,
  internal paths, provisioning snippets) must not be offered. List it in the
  summary as belonging to the work source.

## Step 4 – Ask

Use `AskUserQuestion` with `multiSelect: true`:

- One option per change. Label it with the target path and kind (modified,
  new, removed, renamed); put a one-line summary of the diff in the
  description.
- At most 4 options per question and 4 questions per call. Group by kind and
  make more calls if needed.
- Phrase each question as "Which of these should I add, commit and push to
  `<repo>`?"
- Ask a separate question for new files that weren't selected: "Should
  chezmoi ignore any of these from now on?" Add the chosen ones to
  `$SRC/.chezmoiignore`. In a public repo, never ignore paths whose names are
  employer-specific; those go in the work source's `.chezmoiignore`.

If nothing changed, say so and stop.

## Step 5 – Apply the selection

| Kind | Command |
|---|---|
| modified | `$CZ re-add <target>` |
| new | `$CZ add <target>` |
| removed | `$CZ forget --force <target>` |
| renamed | `$CZ forget --force <old>` then `$CZ add <new>` |
| ignore | Append the target path, relative to `~`, to `$SRC/.chezmoiignore` |

- `re-add` skips templates. If the source file ends in `.tmpl`, don't
  overwrite it: show Sergio the change and edit the template by hand.
- `chezmoi add` stores files whose names end in `.tmpl` as `.tmpl.literal`, so
  they aren't rendered. That's expected.

## Step 6 – Verify

- `$CZ status` must no longer list the selected targets.
- `git -C "$SRC" status --short` must show only the selected changes. Unstage
  anything else.
- **Public repo:** scan the staged diff for employer-specific content and stop
  if anything turns up.

## Step 7 – Commit and push

- Stage only the selected changes, then commit with a short imperative message
  in the repo's style (e.g. "Rename `x` skill to `y`", "Update tmux config").
  Follow the commit attribution rules in force.
- Push to the remote in the table, never to any other remote.
- Report the commit hash and the pushed range, plus anything listed under "not
  applied yet" or "belongs to another source".
