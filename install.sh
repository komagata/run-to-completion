#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/komagata/run-to-completion.git"
install_root="${RUN_TO_COMPLETION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/run-to-completion}"
repo_dir="$install_root/repo"
bin_dir="${RUN_TO_COMPLETION_BIN_DIR:-$HOME/.local/bin}"
bin_link="$bin_dir/run-to-completion"
runner_source="$repo_dir/bin/run-to-completion"
legacy_skill_link="${CODEX_HOME:-$HOME/.codex}/skills/run-to-completion"
legacy_prompt_file="${CODEX_HOME:-$HOME/.codex}/prompts/run-to-completion.md"

log() {
  printf '%s\n' "$*"
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "error: '$1' is required"
    exit 1
  fi
}

need git
need python3

mkdir -p "$install_root" "$bin_dir"

if [ -d "$repo_dir/.git" ]; then
  log "Updating repository: $repo_dir"
  git -C "$repo_dir" pull --ff-only
else
  if [ -e "$repo_dir" ]; then
    backup="$repo_dir.backup.$(date +%Y%m%d%H%M%S)"
    mv "$repo_dir" "$backup"
    log "Backed up existing repository path to $backup"
  fi
  log "Cloning repository: $repo_url"
  git clone "$repo_url" "$repo_dir"
fi

if [ ! -x "$runner_source" ]; then
  log "error: expected runner was not found or executable: $runner_source"
  exit 1
fi

if [ -e "$bin_link" ] || [ -L "$bin_link" ]; then
  if [ -L "$bin_link" ]; then
    rm "$bin_link"
  else
    backup="$bin_link.backup.$(date +%Y%m%d%H%M%S)"
    mv "$bin_link" "$backup"
    log "Backed up existing command to $backup"
  fi
fi

ln -s "$runner_source" "$bin_link"
log "Installed command: $bin_link -> $runner_source"

if [ -L "$legacy_skill_link" ]; then
  rm "$legacy_skill_link"
  log "Removed legacy Codex skill symlink: $legacy_skill_link"
elif [ -e "$legacy_skill_link" ]; then
  backup="$legacy_skill_link.backup.$(date +%Y%m%d%H%M%S)"
  mv "$legacy_skill_link" "$backup"
  log "Backed up legacy Codex skill directory to: $backup"
fi

if [ -f "$legacy_prompt_file" ]; then
  rm "$legacy_prompt_file"
  log "Removed legacy Codex prompt: $legacy_prompt_file"
fi

if command -v codex >/dev/null 2>&1; then
  if codex plugin marketplace remove run-to-completion >/dev/null 2>&1; then
    log "Removed legacy Codex plugin marketplace: run-to-completion"
  fi
fi

log ""
log "run-to-completion is installed."
log ""
log "Start it with:"
log "  run-to-completion \"<your goal>\""
log ""
log "Example:"
log "  run-to-completion \"Fix flaky tests and verify the suite passes\""
log ""
log "If your shell cannot find it, add this to PATH:"
log "  export PATH=\"$bin_dir:\$PATH\""
log ""
log "To update later, run this installer again:"
log "  curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash"
