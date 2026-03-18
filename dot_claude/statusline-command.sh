#!/usr/bin/env bash

# Claude Code status line script
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

# ── Colors ────────────────────────────────────────────────────────────────────
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

COLOR_WHITE="\033[97m"
COLOR_CYAN="\033[96m"
COLOR_YELLOW="\033[93m"
COLOR_GREEN="\033[92m"
COLOR_MAGENTA="\033[95m"
COLOR_BLUE="\033[94m"
COLOR_RED="\033[91m"

# ── Parse JSON fields ─────────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ── User @ Host ───────────────────────────────────────────────────────────────
user=$(whoami)
host=$(hostname -s)

# Hostname is WHITE locally, CYAN over SSH
if [ -n "${SSH_TTY}" ] || [ -n "${SSH_CONNECTION}" ]; then
    host_color="${COLOR_CYAN}"
else
    host_color="${COLOR_WHITE}"
fi

user_host_segment="👤 $(printf "${BOLD}${COLOR_WHITE}%s${RESET}" "${user}")$(printf "${DIM}@${RESET}")$(printf "${BOLD}${host_color}%s${RESET}" "${host}")"

# ── Current directory ─────────────────────────────────────────────────────────
# Replace $HOME with ~ for brevity
display_dir="${cwd/#$HOME/\~}"
dir_segment="📁 $(printf "${BOLD}${COLOR_YELLOW}%s${RESET}" "${display_dir}")"

# ── Git branch ────────────────────────────────────────────────────────────────
branch=""
if command -v git >/dev/null 2>&1; then
    branch=$(git -C "${cwd}" branch --show-current --no-optional-locks 2>/dev/null)
fi

if [ -n "${branch}" ]; then
    git_segment="🌿 $(printf "${COLOR_GREEN}%s${RESET}" "${branch}")"
else
    git_segment=""
fi

# ── Model ─────────────────────────────────────────────────────────────────────
if [ -n "${model}" ]; then
    model_segment="🧠 $(printf "${COLOR_MAGENTA}%s${RESET}" "${model}")"
else
    model_segment=""
fi

# ── Context window usage as a progress bar ────────────────────────────────────
# Uses Unicode block characters: ░ (empty) and █ (filled)
if [ -n "${used_pct}" ]; then
    pct_int=$(printf "%.0f" "${used_pct}")
    bar_width=10
    filled=$(( pct_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    if [ "${pct_int}" -ge 80 ]; then
        bar_color="${COLOR_RED}"
    elif [ "${pct_int}" -ge 50 ]; then
        bar_color="${COLOR_YELLOW}"
    else
        bar_color="${COLOR_BLUE}"
    fi

    bar=""
    for i in $(seq 1 "${filled}"); do bar="${bar}█"; done
    for i in $(seq 1 "${empty}");  do bar="${bar}░"; done

    ctx_segment="📊 $(printf "${bar_color}%s${RESET} ${DIM}%d%%${RESET}" "${bar}" "${pct_int}")"
else
    ctx_segment=""
fi

# ── Assemble segments ─────────────────────────────────────────────────────────
sep="$(printf "${DIM} │ ${RESET}")"

line="${user_host_segment}${sep}${dir_segment}"

[ -n "${git_segment}" ]   && line="${line}${sep}${git_segment}"
[ -n "${model_segment}" ] && line="${line}${sep}${model_segment}"
[ -n "${ctx_segment}" ]   && line="${line}${sep}${ctx_segment}"

printf "%b\n" "${line}"
