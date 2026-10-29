# dotfiles

My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/): zsh
(Oh My Zsh + Powerlevel10k), tmux, mise, and shared rules and skills for coding
agents in `~/.agents`.

## Install

On a new machine (macOS or Linux):

```sh
curl -fsSL https://raw.githubusercontent.com/sergiomercado19/dotfiles/main/install.sh | bash
```

`install.sh` installs git, zsh, tmux, mise, chezmoi, Oh My Zsh (with
zsh-autosuggestions and zsh-syntax-highlighting) and Powerlevel10k, clones this
repo to `~/.local/share/chezmoi`, applies it, and makes zsh the default shell.
It's safe to re-run: every step skips what's already installed. It needs `curl`
and `sudo`, and works unattended with passwordless sudo.

To install from a fork, set `GITHUB_USERNAME` before running it.

## Day to day

```sh
chezmoi diff      # preview what would change in ~
chezmoi apply     # apply the source to ~
chezmoi update    # pull this repo, then apply
chezmoi edit ~/.zshrc
```

## What's in here

| Source | Target | Notes |
|---|---|---|
| `dot_zshenv` | `~/.zshenv` | Every shell: `SHELL`, `EDITOR`, `LANG` |
| `dot_zprofile` | `~/.zprofile` | Login shells: Homebrew, `PATH`; sources `~/.zprofile_work` if present |
| `dot_zshrc` | `~/.zshrc` | Interactive shells: Oh My Zsh, p10k, mise, device profiles |
| `dot_zshrc_desktop` | `~/.zshrc_desktop` | Sourced on WSL |
| `dot_p10k.zsh` | `~/.p10k.zsh` | Powerlevel10k config (`p10k configure` regenerates it) |
| `dot_tmux.conf` | `~/.tmux.conf` | tmux config |
| `dot_agents/rules/` | `~/.agents/rules/` | Rules for coding agents |
| `dot_agents/skills/` | `~/.agents/skills/` | Skills for coding agents |
| `install.sh`, `install.test.sh` | — | Repo-only, see `.chezmoiignore` |

### Device profiles

`~/.zshrc` sources extra config depending on the machine:

- **WSL:** `~/.zshrc_desktop`.
- **Work machines:** `~/.zshrc_work` and `~/.zprofile_work` (from `~/.zprofile`),
  if they exist. These files come from a separate, private work dotfiles repo
  applied as a second chezmoi source. This repo only contains the hooks that
  source them.

## Personal vs work

This repo is public and holds only personal, generic config. Anything specific
to an employer (internal tools, hostnames, ticket projects, internal paths,
provisioning snippets) lives in the private work dotfiles repo instead. The two
repos never manage the same file.

To see which repo owns a skill:

```sh
chezmoi managed --include=dirs | grep '^.agents/skills/[^/]*$'
```

Skills not listed there come from the work repo.

## Tests

```sh
bash install.test.sh
```

Unit tests for the functions in `install.sh`. They pass on macOS (BSD tools) and
Linux (GNU tools).

## History

This repo's history starts on 2026-10-29, when personal and work dotfiles were
split into separate repos.
