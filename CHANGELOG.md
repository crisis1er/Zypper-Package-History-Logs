# Changelog

All notable changes to this project are documented in this file.

---

## [5.1] — 2026-04-06

### Added
- `-g / --downgrades [N]` — retroactive downgrade detection: finds packages removed and reinstalled on the same day (heuristic), over the last N active days (default: 30). Shows old version → new version and repository.
- `-G / --dup-log` — displays `/var/log/zypper-changes-detailed.log` with `less -R`, written by the companion `zyp-dup` wrapper before each `zypper dup`.
- `radd` / `rremove` display in `display_history()` — repository add/remove events now appear as a "DÉPÔTS" section, colorized (green for radd, red for rremove).

### Changed
- `color_action()` extended to handle `radd` (green) and `rremove` (red)
- Help updated with new flags and examples
- Version bump: 5.0 → 5.1

### New companion script
- `zyp-dup` — wrapper for `zypper dup` that runs a dry-run first, parses downgrades/vendor changes/removals, displays a colored summary with current versions, logs all details to `/var/log/zypper-changes-detailed.log`, and asks confirmation before running the actual upgrade.

---

## [5.0] — 2026-04-06

### Added
- `-i / --installs` — filter installs only for a given date
- `-r / --removes` — filter removals only for a given date
- `-p / --package NAME` — search a package across the entire history (all dates)
- `-l / --last N` — display the last N days of activity in one pass
- `-s / --stats` — global statistics: totals, top 10 installed/removed packages, activity per repo and per day
- `-d / --date YYYY-MM-DD` — specify date directly without interactive prompt
- Flags are combinable: `-i -d 2026-04-01`, `-r -l 7`, etc.

### Changed
- Extracted `display_history()` as a reusable internal function — all display paths use the same colorized renderer
- Updated help (`-h`) with all new flags and examples
- Version bump: 4.2 → 5.0

## [4.2] — 2026-04-04

### Added
- Interactive listing of all days with recorded zypper activity, showing package and command counts per day
- Dynamic repository color assignment at runtime via `zypper repos` — works with any user repository configuration

### Changed
- `color_depot()` refactored to use a runtime-built lookup map instead of hardcoded repository names
- Fixed empty-string array key error when parsing `zypper repos` output

### Internal
- Version bump to 4.2
- Repository restructured: legacy scripts moved to `archive/`, main script renamed to `zypper-history`

---

## [4.1] — 2025-11-09

### Added
- Full ANSI color support for actions (install/remove) and repositories
- CSV export to `~/Audits/` with restricted permissions (`600`)
- Paginated output via `less -R`
- Multi-language message system (French)
- Strict date validation (format, calendar bounds, future date rejection)
- Root check with interactive sudo fallback
- `-h` / `--help` and `-v` / `--version` flags

### Changed
- Complete rewrite with `set -euo pipefail` and safe IFS
- Modular structure with dedicated functions per concern

---

## [2.0] — 2025-01-27

### Added
- Support for `command` actions from `/var/log/zypp/history`
- Captures zypper operations: `refresh`, `up`, `dup`, etc.
- Unified view of package and command activity for a given date

---

## [1.1] — 2025-01-25

### Added
- Initial script: parses `install` and `remove` actions from `/var/log/zypp/history`
- Filters by current date using `date '+%Y-%m-%d'`
- Formatted `awk` output with aligned columns
