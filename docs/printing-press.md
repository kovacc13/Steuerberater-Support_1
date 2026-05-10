# Printing Press Setup

This branch installs the [Printing Press](https://printingpress.dev) factory and
its starter-pack CLIs into the Claude Code environment used to support this
project. Printing Press prints token-efficient Go CLIs designed for AI agents,
which trades MCP-style verbose tool surfaces for compact CLI calls and
significantly lower token spend.

## What gets installed

**Factory binary** (`printing-press`, v4.2.2)
The engine that researches an API, generates a Go CLI plus an MCP server, runs
verification, and ships the result. Backs every `/printing-press*` skill.

**Starter pack CLIs** (each ships a CLI plus an MCP server)
- `espn-pp-cli` / `espn-pp-mcp` — live scores, standings, box scores, head-to-head, polls (no API key)
- `flight-goat-pp-cli` / `flight-goat-pp-mcp` — Google Flights + Kayak nonstop search, FlightAware tracking
- `movie-goat-pp-cli` / `movie-goat-pp-mcp` — TMDb + OMDb ratings, streaming availability, watchlist
- `recipe-goat-pp-cli` / `recipe-goat-pp-mcp` — recipe ranking across 37 trusted sites, pantry match

**Claude Code skills** (in `~/.claude/skills/`)
- `/printing-press`, `/printing-press-catalog`, `/printing-press-import`,
  `/printing-press-polish`, `/printing-press-publish`, `/printing-press-reprint`,
  `/printing-press-retro`, `/printing-press-score`, plus the
  `printing-press-output-review` sub-skill
- Focused per-CLI skills: `/pp-espn`, `/pp-flight-goat`, `/pp-movie-goat`,
  `/pp-recipe-goat`

## Prerequisites

- Go 1.21+ with `GOTOOLCHAIN=auto` (the repos require Go 1.26.3; the auto
  toolchain downloads it transparently on the first build)
- `git`
- A Claude Code session with `~/.claude/skills/` writable

## Reproducing the install

```bash
bash scripts/setup-printing-press.sh
```

The script is idempotent: re-running pulls the latest factory and library,
rebuilds binaries into `$HOME/go/bin`, refreshes symlinks in `$HOME/.local/bin`,
and replaces the skill folders under `$HOME/.claude/skills/`.

To install only the factory (skip the four starter CLIs):

```bash
FACTORY_ONLY=1 bash scripts/setup-printing-press.sh
```

## Quick check

```bash
printing-press --version          # 4.2.2
espn-pp-cli --help                # subcommand list
ls ~/.claude/skills | grep -E '^(pp-|printing-press)'
```

Inside Claude Code, the focused skills appear as slash commands once the
session reloads its skill index.

## Printing a new CLI

After install, point the factory at any API or website:

```text
/printing-press Notion
/printing-press https://news.ycombinator.com
```

The factory researches the surface, generates a Go module under
`~/printing-press/library/<name>/`, builds the CLI plus an MCP server, and
prints a Quality Score against the Steinberger bar.

## Source repos

- Factory: https://github.com/mvanhorn/cli-printing-press
- Library / starter pack: https://github.com/mvanhorn/printing-press-library
- Catalog: https://printingpress.dev
