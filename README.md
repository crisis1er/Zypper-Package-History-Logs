[![Visitors](https://visitor-badge.laobi.icu/badge?page_id=crisis1er.Zypper-Package-History-Logs)](https://github.com/crisis1er/Zypper-Package-History-Logs)
![Version](https://img.shields.io/badge/version-v5.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-openSUSE%20Tumbleweed-73BA25)
![Shell](https://img.shields.io/badge/shell-bash%205%2B-4EAA25)
![Ecosystem](https://img.shields.io/badge/ecosystem-zsh--opensuse--tumbleweed-orange)

# Zypper-Package-History-Logs

Part of the **[zsh-opensuse-tumbleweed](https://github.com/crisis1er/zsh-opensuse-tumbleweed)** plugin ecosystem — a collection of tools and Oh My Zsh plugins built for daily openSUSE Tumbleweed administration.

This repository provides two companion scripts:

- **`zypper-history`** — audit tool that parses `/var/log/zypp/history` with color-coded output, filters, package search, statistics, and retroactive downgrade detection
- **`zyp-dup`** — `zypper dup` wrapper that runs a dry-run first, detects downgrades / vendor changes / removals before they happen, and logs everything for later review

---

## zypper-history

### Features

- **Date-based filtering** — query any date, or default to today
- **Available dates listing** — view all days with recorded zypper activity before selecting
- **Color-coded output** — actions (install/remove) and repositories highlighted with distinct ANSI colors
- **Dynamic repository coloring** — detects all configured repositories at runtime, assigns unique colors automatically
- **Install / remove filters** — `-i` or `-r` to show only one action type
- **Package search** — `-p NAME` searches the entire history across all dates
- **Last N days** — `-l N` displays the N most recent days of activity in one pass
- **Global statistics** — `-s` shows totals, top 10 installed/removed packages, activity per repository and per day
- **Retroactive downgrade detection** — `-g [N]` finds packages removed and reinstalled on the same day (heuristic), over the N last active days
- **zyp-dup log viewer** — `-G` opens `/var/log/zypper-changes-detailed.log` (written by `zyp-dup`) in `less -R`
- **Repository add/remove display** — `radd` and `rremove` events shown as a dedicated DÉPÔTS section
- **CSV export** — generate structured reports saved to `~/Audits/` with permissions `600`
- **Paginated display** — output piped through `less -R` with search support
- **Root check with sudo fallback** — prompts for privilege escalation if needed
- **Strict date validation** — rejects malformed or future dates

### Usage

```bash
zypper-history                    # Interactive mode (default)
zypper-history -d YYYY-MM-DD      # Specific date directly
zypper-history -i [-d DATE]       # Installs only
zypper-history -r [-d DATE]       # Removals only
zypper-history -p curl            # Search package across entire history
zypper-history -l 7               # Last 7 active days
zypper-history -s                 # Global statistics
zypper-history -g                 # Retroactive downgrade detection (last 30 active days)
zypper-history -g 60              # Same, over 60 active days
zypper-history -G                 # View zyp-dup detailed log
zypper-history -h                 # Help
zypper-history -v                 # Version
```

Flags are combinable: `-i -d 2026-04-01`, `-r -l 7`, etc.

### Output format

```
COMMANDS (manual) - 2026-04-06
====================================================================================
Date/Time            | Type    | User               | Command
====================================================================================
2026-04-06 09:12:31  | command | root               | zypper dup

PACKAGES (install/removal) - 2026-04-06
====================================================================================
Date/Time            | Action   | Package                     | Version      | Arch
====================================================================================
2026-04-06 09:13:05  | install  | curl                        | 8.11.1-1.1   | x86_64
  └─ Repository: repo-oss
2026-04-06 09:13:07  | remove   | curl-old                    | 8.10.0-1.1   | x86_64
  └─ Repository: repo-update

DÉPÔTS (add/remove) - 2026-04-06
====================================================================================
Date/Time            | Action   | Alias/URL
====================================================================================
2026-04-06 10:00:00  | radd     | packman  https://ftp.gwdg.de/pub/linux/misc/packman/...
```

### Retroactive downgrade detection (`-g`)

`/var/log/zypp/history` records no explicit `downgrade` action — only `install` and `remove`. The `-g` flag detects candidates by finding packages that appear as both `remove` and `install` on the same day, then shows the version transition:

```
DOWNGRADES / RÉINSTALLATIONS DÉTECTÉS
(heuristique : paquet supprimé + réinstallé le même jour)
====================================================================================

2026-04-06
  ▼ kernel-default  6.12.14-1.1 → 6.12.13-1.1  [repo-oss]
```

For pre-execution downgrade detection, use `zyp-dup` (see below).

---

## zyp-dup

`zypper dup` modifies the system silently. Downgrades, vendor changes, and unexpected removals are listed in the output but gone as soon as the terminal closes. `zyp-dup` captures this information before anything is installed.

### What it does

1. Runs `LANG=C zypper --non-interactive dup --dry-run`
2. Parses five sections: upgrades, new packages, downgrades, vendor changes, removals
3. Displays a color-coded summary — critical changes highlighted in red/yellow with current version via `rpm -q`
4. Logs the full pre-dup analysis to `/var/log/zypper-changes-detailed.log` with timestamp
5. Asks for confirmation before running the actual `zypper dup`
6. Logs start and end timestamps of the real upgrade

### Usage

```bash
zyp-dup              # Run zypper dup with full pre-analysis
zyp-dup --no-recommends   # Any zypper dup flag is passed through
```

### Example output

```
╔══════════════════════════════════════════════════════════════╗
║         zyp-dup — Analyse pré-mise à jour                    ║
╚══════════════════════════════════════════════════════════════╝

Résumé de la mise à jour :
══════════════════════════════════════════════════════════════
  ▶ Upgrades    : 47
  ▶ Nouveaux    : 2
  ▼ Downgrades  : 1 ← ATTENTION
  ⇄ Chgt fournisseur : 0
  ✕ Suppressions : 0
══════════════════════════════════════════════════════════════

⚠️  Paquets qui vont être réduits (DOWNGRADE) :
  ▼ kernel-default  (actuellement : 6.12.14-1.1)

Log sauvegardé dans : /var/log/zypper-changes-detailed.log

Lancer zypper dup ? [O/n]
```

### Reviewing the log

```bash
zypper-history -G    # View the log inside zypper-history (less -R)
cat /var/log/zypper-changes-detailed.log
```

---

## Installation

```bash
# zypper-history
sudo curl -o /usr/local/bin/zypper-history \
  https://raw.githubusercontent.com/crisis1er/Zypper-Package-History-Logs/main/zypper-history
sudo chmod +x /usr/local/bin/zypper-history

# zyp-dup
sudo curl -o /usr/local/bin/zyp-dup \
  https://raw.githubusercontent.com/crisis1er/Zypper-Package-History-Logs/main/zyp-dup
sudo chmod +x /usr/local/bin/zyp-dup
```

Or clone:

```bash
git clone https://github.com/crisis1er/Zypper-Package-History-Logs.git
sudo cp Zypper-Package-History-Logs/zypper-history /usr/local/bin/
sudo cp Zypper-Package-History-Logs/zyp-dup /usr/local/bin/
sudo chmod +x /usr/local/bin/zypper-history /usr/local/bin/zyp-dup
```

---

## Requirements

| Dependency | Purpose |
|------------|---------|
| `bash 5+` | Script runtime |
| `zypper` | Repository listing and history source |
| `rpm` | Current version query (`zyp-dup`) |
| `awk` | Log parsing and formatting |
| `less` | Paginated terminal output |

Tested on **openSUSE Tumbleweed**.

---

## Color reference

| Color | Meaning |
|-------|---------|
| 🟢 Green bold | Package installed |
| 🔴 Red bold | Package removed / downgrade |
| 🟡 Yellow | Vendor change / important warning |
| 🔵 Blue | `repo-oss` — official openSUSE OSS |
| 🔷 Cyan | `repo-update` — official updates |
| 🟡 Yellow | `packman` — community multimedia |
| Dynamic | All other repositories — unique color assigned at runtime |
| ⚪ Grey | Unknown or unresolved repository |

---

## Part of the zsh-opensuse-tumbleweed ecosystem

This repository is developed as part of **[crisis1er/zsh-opensuse-tumbleweed](https://github.com/crisis1er/zsh-opensuse-tumbleweed)**, a set of tools and Oh My Zsh plugins for openSUSE Tumbleweed daily administration:

| Repository | Description |
|------------|-------------|
| [zsh-opensuse-tumbleweed](https://github.com/crisis1er/zsh-opensuse-tumbleweed) | Hub — shared zsh config, HISTSIZE, themes |
| [zsh-snap-new](https://github.com/crisis1er/zsh-snap-new) | Guided interactive Btrfs snapshot creation |
| [zsh-snap-list](https://github.com/crisis1er/zsh-snap-list) | Colorized snapper listing with filters and menu |
| [zsh-btrfs-snapper](https://github.com/crisis1er/zsh-btrfs-snapper) | Full Btrfs + snapper command set |
| **Zypper-Package-History-Logs** | **Zypper audit + dup wrapper (this repo)** |

---

## Contributing

Bug reports, suggestions, and pull requests are welcome.

- Open an [issue](https://github.com/crisis1er/Zypper-Package-History-Logs/issues) for bugs or feature requests
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines

Please include your openSUSE version, kernel version, and zypper version in bug reports.

---

## Archive

Previous versions are available in the [`archive/`](archive/) directory.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
