# AGENTS.md

Instructions for coding agents working in this repo. Read `README.md` first for
what the repo is and how it's laid out.

## This repo is public

- Never add employer-specific content: company or product names, internal tools,
  internal hostnames or URLs, ticket projects, internal repo paths, provisioning
  snippets, or the work dotfiles repo's URL. That content belongs in the private
  work dotfiles repo.
- If a file is mostly generic but has a few work-specific details, generalise it
  (e.g. "the repo the PR belongs to" instead of an internal checkout path). If
  that's not possible, the file belongs in the work repo.
- Before committing, scan the staged files for anything that identifies an
  employer or its internal systems, and stop and ask if anything turns up.

## Two chezmoi sources share `~`

This repo is the default chezmoi source (`~/.local/share/chezmoi`). On work
machines, a second source (the work repo) is applied on top with its own config
and state. To keep them from fighting:

- Never manage a target that the work source manages. The work source owns
  `~/.zshrc_work`, `~/.zprofile_work`, `~/.claude/`, and its own skill
  directories under `~/.agents/skills/`.
- Never use the `exact_` prefix on `dot_agents/` or `dot_agents/skills/`: both
  sources write into those directories, and `exact_` would delete the other
  source's files.
- Machine-specific config goes in a separate file that this repo only sources if
  it exists (the `~/.zshrc_work` / `~/.zprofile_work` pattern), never inline.

## chezmoi conventions

- Source names use chezmoi prefixes and suffixes: `dot_` becomes `.`,
  `symlink_` creates a symlink, `.tmpl` is rendered as a template, and
  `.literal` stops suffix parsing (so `foo.tmpl.literal` deploys as `foo.tmpl`
  without being rendered).
- Files that belong to the repo but not to `~` (docs, scripts, tests) must be
  listed in `.chezmoiignore`, or chezmoi deploys them to `~`.
- Use `chezmoi diff` to check changes. Don't run `chezmoi apply` or
  `chezmoi update` unless asked: they overwrite files in `~`.
- If `chezmoi diff` shows changes you didn't make, the live file has drifted
  from the source. Ask which version is correct before overwriting either one.

## `install.sh`

- It must run unattended on a fresh machine with passwordless sudo and no user
  password, e.g. `sudo chsh -s "$(which zsh)" "$USER"`, not plain `chsh`.
- It must stay safe to re-run: every step skips what's already done.
- The work repo's bootstrap clones this repo anonymously over HTTPS and runs
  this script, so this repo must stay publicly readable and `install.sh` must
  stay at the repo root.

## Tests

- Run `bash install.test.sh` after changing `install.sh` or the tests. It must
  pass on both macOS (BSD tools) and Linux (GNU tools), with clean output.
- The tests load `install.sh` from `~/.local/share/chezmoi`, not from the
  directory the test file is in.
- Keep shell code portable between BSD and GNU tools (e.g. no `head -n -1`, no
  `sed -i` without a backup suffix argument).
- Strip or select lines by content, not by line number.
- Any function a test replaces (such as `exit`) must be removed (`unset -f`) at
  the end of that test.

## Git

- Commit and push only when explicitly asked.
- Work-specific commits must never be pushed here, even temporarily: a push to
  a public repo can be cached or forked before it's undone.
