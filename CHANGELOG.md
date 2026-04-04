# Changelog

All notable changes to this project are documented in this file.

---

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
