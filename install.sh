#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
FORCE=0

if [[ -n "${NO_COLOR:-}" ]]; then
  COLOR=0
elif [[ -n "${FORCE_COLOR:-}" ]]; then
  COLOR=1
elif [[ -t 1 ]]; then
  COLOR=1
else
  COLOR=0
fi

if [[ "$COLOR" -eq 1 ]]; then
  C_RESET=$'\033[0m'
  C_RED=$'\033[1;31m'
  C_GREEN=$'\033[1;32m'
  C_YELLOW=$'\033[1;33m'
  C_BLUE=$'\033[1;34m'
  C_CYAN=$'\033[1;36m'
  C_DIM=$'\033[2m'
else
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_CYAN=""
  C_DIM=""
fi

usage() {
  cat <<'EOF'
Usage: ./install.sh [--force] [--help]

Installs Tinava assets into the current user's XDG data directory.

Options:
  --force  Replace existing files or directories
  --help   Show this help
EOF
}

log() {
  printf '%s\n' "$*"
}

info() {
  printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"
}

success() {
  printf '%sInstalled:%s %s\n' "$C_GREEN" "$C_RESET" "$*"
}

skip() {
  printf '%sSkip:%s %s\n' "$C_YELLOW" "$C_RESET" "$*"
}

fail() {
  printf '%sError:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2
  exit 1
}

replace_destination() {
  local dest="$1"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
      fail "Destination already exists: $dest (use --force to replace it)"
    fi
    rm -rf -- "$dest"
  fi
}

install_copy() {
  local src="$1"
  local dest="$2"

  replace_destination "$dest"
  mkdir -p -- "$(dirname -- "$dest")"
  cp -a -- "$src" "$dest"
}

install_item() {
  local relative_src="$1"
  local relative_dest="$2"
  local src_path="$SCRIPT_DIR/$relative_src"
  local dest_path="$DATA_HOME/$relative_dest"

  if [[ ! -e "$src_path" ]]; then
    skip "$relative_src not found"
    return 0
  fi

  install_copy "$src_path" "$dest_path"

  success "$relative_src -> $dest_path"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
  shift
done

install_item "desktoptheme/tinava" "plasma/desktoptheme/tinava"
install_item "desktoptheme/tinava-bright-accent" "plasma/desktoptheme/tinava-bright-accent"
install_item "color-schemes/Tinava.colors" "color-schemes/Tinava.colors"
install_item "color-schemes/TinavaLight.colors" "color-schemes/TinavaLight.colors"
install_item "konsole/Tinava.colorscheme" "konsole/Tinava.colorscheme"
log
info "Tinava installation complete"
log "${C_DIM}Data dir:${C_RESET} $DATA_HOME"
log
info "Apply manually in:"
log "  ${C_CYAN}Plasma Style:${C_RESET} System Settings -> Colors & Themes -> Plasma Style (Tinava or Tinava Bright Accent)"
log "  ${C_CYAN}Colors:${C_RESET} System Settings -> Colors & Themes -> Colors (Tinava or Tinava Light)"
log "  ${C_CYAN}Konsole:${C_RESET} Settings -> Edit Current Profile -> Appearance"
