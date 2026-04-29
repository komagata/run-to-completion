#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/komagata/run-to-completion.git"
install_root="${RUN_TO_COMPLETION_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/run-to-completion}"
repo_dir="$install_root/repo"
codex_home="${CODEX_HOME:-$HOME/.codex}"
skills_dir="$codex_home/skills"
skill_link="$skills_dir/run-to-completion"
skill_source="$repo_dir/run-to-completion"
plugin_registered=0

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

if command -v codex >/dev/null 2>&1; then
  log "Registering Codex plugin marketplace: $repo_dir"
  if ! codex plugin marketplace add "$repo_dir"; then
    log "warning: Codex plugin registration failed. Update Codex CLI, then run this installer again to enable /run-to-completion."
  else
    plugin_registered=1
  fi
else
  log "Codex CLI was not found; skipped plugin marketplace registration."
fi

log ""
log "run-to-completion is installed."
log ""
log "Codex skill path:"
log "  $skill_link"
log ""
if [ "$plugin_registered" = "1" ]; then
  log "Start it in Codex with:"
  log "  /run-to-completion <your goal>"
  log ""
  log "You can also force-load the skill with:"
  log "  /use run-to-completion"
else
  log "Start it in Codex by force-loading the skill:"
  log "  /use run-to-completion"
  log ""
  log "After plugin registration succeeds, this slash command will also work:"
  log "  /run-to-completion <your goal>"
fi
log ""
log "Claude Code import:"
log "  @$skill_source/CLAUDE.md"
log ""
log "To update later, run this installer again:"
log "  curl -fsSL https://raw.githubusercontent.com/komagata/run-to-completion/main/install.sh | bash"
