#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/komagata/run-to-completion.git"
install_root="${RUN_TO_COMPLETION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/run-to-completion}"
repo_dir="$install_root/repo"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skills_dir="$codex_home/skills"
skill_link="$skills_dir/run-to-completion"
skill_source="$repo_dir/run-to-completion"

log() {
  printf '%s\n' "$*"
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "error: '$1' is required"
    exit 1
  fi
}

backup_existing() {
  if [ -e "$skill_link" ] || [ -L "$skill_link" ]; then
    if [ -L "$skill_link" ]; then
      rm "$skill_link"
    else
      backup="$skill_link.backup.$(date +%Y%m%d%H%M%S)"
      mv "$skill_link" "$backup"
      log "Backed up existing skill to $backup"
    fi
  fi
}

need git

mkdir -p "$install_root" "$skills_dir"

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

if [ ! -f "$skill_source/SKILL.md" ]; then
  log "error: expected skill file was not found: $skill_source/SKILL.md"
  exit 1
fi

backup_existing

if ln -s "$skill_source" "$skill_link" 2>/dev/null; then
  log "Installed Codex skill symlink: $skill_link -> $skill_source"
else
  cp -R "$skill_source" "$skill_link"
  log "Symlink failed; copied Codex skill to: $skill_link"
fi

log ""
log "run-to-completion is installed."
log ""
log "Codex skill path:"
log "  $skill_link"
log ""
log "Start it in Codex with a normal prompt, not a slash command:"
log "  Use run-to-completion. Goal: <your goal>"
log ""
log "Claude Code import:"
log "  @$skill_source/CLAUDE.md"
log ""
log "To update later, run this installer again:"
log "  curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash"
