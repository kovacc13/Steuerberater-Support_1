#!/usr/bin/env bash
# Idempotent installer for the Printing Press CLI factory plus the starter pack.
# Builds Go binaries from source, links them into PATH, and copies Claude Code
# skills into ~/.claude/skills.
#
# Usage:
#   bash scripts/setup-printing-press.sh           # full install
#   FACTORY_ONLY=1 bash scripts/setup-printing-press.sh  # skip starter pack
#
# Requirements:
#   - git
#   - Go 1.21+ (with GOTOOLCHAIN=auto so go.mod can pull a newer toolchain)

set -euo pipefail

WORK_DIR="${WORK_DIR:-${TMPDIR:-/tmp}/printing-press-setup}"
GOBIN="${GOBIN:-$HOME/go/bin}"
LINK_DIR="${LINK_DIR:-$HOME/.local/bin}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
FACTORY_REPO="https://github.com/mvanhorn/cli-printing-press.git"
LIBRARY_REPO="https://github.com/mvanhorn/printing-press-library.git"

export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"

log() { printf '[printing-press] %s\n' "$*"; }

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing dependency: $1" >&2; exit 1; }
}

require git
require go

mkdir -p "$WORK_DIR" "$GOBIN" "$LINK_DIR" "$SKILLS_DIR"

clone_or_update() {
  local url="$1" dir="$2"
  if [ -d "$dir/.git" ]; then
    log "updating $(basename "$dir")"
    git -C "$dir" pull --ff-only --quiet
  else
    log "cloning $(basename "$dir")"
    git clone --quiet "$url" "$dir"
  fi
}

clone_or_update "$FACTORY_REPO" "$WORK_DIR/cli-printing-press"
clone_or_update "$LIBRARY_REPO" "$WORK_DIR/printing-press-library"

build_bin() {
  local module_dir="$1" cmd_pkg="$2" out_name="$3"
  log "building $out_name"
  (cd "$module_dir" && go build -o "$GOBIN/$out_name" "./$cmd_pkg")
  ln -sf "$GOBIN/$out_name" "$LINK_DIR/$out_name"
}

# Factory binary
build_bin "$WORK_DIR/cli-printing-press" "cmd/printing-press" "printing-press"

if [ "${FACTORY_ONLY:-0}" != "1" ]; then
  LIB="$WORK_DIR/printing-press-library/library"
  # ESPN
  build_bin "$LIB/media-and-entertainment/espn" "cmd/espn-pp-cli" "espn-pp-cli"
  build_bin "$LIB/media-and-entertainment/espn" "cmd/espn-pp-mcp" "espn-pp-mcp"
  # flight-goat
  build_bin "$LIB/travel/flight-goat" "cmd/flight-goat-pp-cli" "flight-goat-pp-cli"
  build_bin "$LIB/travel/flight-goat" "cmd/flight-goat-pp-mcp" "flight-goat-pp-mcp"
  # movie-goat
  build_bin "$LIB/media-and-entertainment/movie-goat" "cmd/movie-goat-pp-cli" "movie-goat-pp-cli"
  build_bin "$LIB/media-and-entertainment/movie-goat" "cmd/movie-goat-pp-mcp" "movie-goat-pp-mcp"
  # recipe-goat
  build_bin "$LIB/food-and-dining/recipe-goat" "cmd/recipe-goat-pp-cli" "recipe-goat-pp-cli"
  build_bin "$LIB/food-and-dining/recipe-goat" "cmd/recipe-goat-pp-mcp" "recipe-goat-pp-mcp"
fi

install_skill() {
  local src="$1" name
  name="$(basename "$src")"
  log "installing skill $name"
  rm -rf "$SKILLS_DIR/$name"
  cp -r "$src" "$SKILLS_DIR/$name"
}

# Factory skills (the /printing-press family)
for skill in printing-press printing-press-catalog printing-press-import \
             printing-press-output-review printing-press-polish \
             printing-press-publish printing-press-reprint \
             printing-press-retro printing-press-score; do
  install_skill "$WORK_DIR/cli-printing-press/skills/$skill"
done

if [ "${FACTORY_ONLY:-0}" != "1" ]; then
  for skill in pp-espn pp-flight-goat pp-movie-goat pp-recipe-goat; do
    install_skill "$WORK_DIR/printing-press-library/cli-skills/$skill"
  done
fi

log "done"
log "binaries:  $LINK_DIR (linked from $GOBIN)"
log "skills:    $SKILLS_DIR"
log "verify:    printing-press --version"
case ":$PATH:" in
  *":$LINK_DIR:"*) ;;
  *) log "note: $LINK_DIR is not on PATH; add it to your shell rc" ;;
esac
