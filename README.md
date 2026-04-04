# zypper-history

![Version](https://img.shields.io/badge/version-4.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-openSUSE%20Tumbleweed%20%7C%20Leap-73BA25)
![Shell](https://img.shields.io/badge/shell-bash%205%2B-4EAA25)

A professional audit tool for openSUSE systems that parses and displays Zypper package management history with color-coded output, CSV export, and dynamic repository identification.

---

## Features

- **Date-based filtering** — query any date from the zypper history log
- **Available dates listing** — view all days with recorded zypper activity before selecting a date
- **Color-coded output** — packages, actions, and repositories are highlighted with distinct ANSI colors
- **Dynamic repository coloring** — automatically detects all configured repositories and assigns unique colors; works with any repository setup
- **CSV export** — generate structured reports for archiving or auditing
- **Paginated display** — output piped through `less -R` with search support
- **Root check with sudo fallback** — prompts for privilege escalation if needed
- **Strict date validation** — rejects malformed or future dates

---

## Requirements

| Dependency | Purpose |
|------------|---------|
| `bash 5+` | Script runtime |
| `zypper` | Repository listing and history source |
| `awk` | Log parsing and formatting |
| `less` | Paginated terminal output |
| `date` | Date validation |

Tested on **openSUSE Tumbleweed** (kernel 6.x) and **openSUSE Leap 15.x**.

---

## Installation

```bash
sudo curl -o /usr/local/bin/zypper-history \
  https://raw.githubusercontent.com/crisis1er/Zypper-Package-History-Logs/main/zypper-history

sudo chmod +x /usr/local/bin/zypper-history
```

Or clone the repository:

```bash
git clone https://github.com/crisis1er/Zypper-Package-History-Logs.git
sudo cp Zypper-Package-History-Logs/zypper-history /usr/local/bin/
sudo chmod +x /usr/local/bin/zypper-history
```

---

## Usage

```bash
zypper-history            # Interactive mode (default)
zypper-history -h         # Show help
zypper-history -v         # Show version
```

### Interactive workflow

```
1. List days with zypper activity? [Y/n]
   → Displays all dates with recorded actions (installs/removals/commands)

2. Specify a date? [Y/n]
   → Yes: enter date in YYYY-MM-DD format
   → No:  defaults to today

3. Output format: [T]erminal or [F]ile CSV? [T/f]
   → Terminal: paginated colored output (searchable with /)
   → CSV:      saved to ~/Audits/zypper-history-YYYY-MM-DD.csv
```

### Keyboard shortcuts (terminal mode)

| Key | Action |
|-----|--------|
| `/` + term + `Enter` | Search for a package or command |
| `n` | Next search result |
| `q` | Quit |

---

## Output format

### Available dates listing

```
📅 Days with zypper activity:
====================================================================================
  📅 2026-03-29    12 package(s) installed/removed    3 command(s)
  📅 2026-04-01     4 package(s) installed/removed    1 command(s)
  📅 2026-04-04     7 package(s) installed/removed    2 command(s)
====================================================================================
```

### Terminal output

```
COMMANDS (manual) - 2026-04-04
====================================================================================
Date/Time            | Type    | User               | Command
====================================================================================
2026-04-04 09:12:31  | command | root               | zypper dup

PACKAGES (install/removal) - 2026-04-04
====================================================================================
Date/Time            | Action   | Package                     | Version      | Arch
====================================================================================
2026-04-04 09:13:05  | install  | curl                        | 8.11.1-1.1   | x86_64
  └─ Repository: repo-oss
2026-04-04 09:13:07  | remove   | curl-old                    | 8.10.0-1.1   | x86_64
  └─ Repository: repo-update
```

### CSV export

```
Date,Time,Type,Action,User,Package,Version,Architecture,Repository,Command
2026-04-04,09:12:31,command,,root,,,,,zypper dup
2026-04-04,09:13:05,package,install,,curl,8.11.1-1.1,x86_64,repo-oss,
```

CSV files are saved to `~/Audits/` with permissions `600`.

---

## Color reference

### Actions

| Color | Meaning |
|-------|---------|
| 🟢 Green | Package installed |
| 🔴 Red | Package removed |

### Repositories

| Color | Repository |
|-------|-----------|
| 🔵 Blue | `repo-oss` — official openSUSE OSS |
| 🔷 Cyan | `repo-update` — official updates |
| 🟡 Yellow | `packman` — community multimedia |
| Dynamic | All other repositories — unique color assigned automatically at runtime |
| ⚪ Grey | Unknown or unresolved repository |

> Repository colors are assigned dynamically from a palette at startup using `zypper repos`. Every user's repository configuration is automatically recognized — no hardcoding required.

---

## CSV report example

```bash
# Generate a report for a specific date
zypper-history
# → Enter date: 2026-03-29
# → Output: F
# → File saved: /home/user/Audits/zypper-history-2026-03-29.csv
```

---

## Use cases

| Scenario | How this tool helps |
|----------|-------------------|
| Post-update regression | Identify exactly which packages changed and from which repository |
| Security audit | Track all installations and removals with timestamps |
| Admin handover | Export a CSV report of all changes during a maintenance window |
| Debugging broken dependencies | Correlate system failures with specific package versions |

---

## Contributing

Bug reports, suggestions, and pull requests are welcome.

- Open an [issue](https://github.com/crisis1er/Zypper-Package-History-Logs/issues) for bugs or feature requests
- See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
- Join the [Discussions](https://github.com/crisis1er/Zypper-Package-History-Logs/discussions)

Please include your openSUSE version, kernel version, and zypper version in bug reports.

---

## Archive

Previous versions are available in the [`archive/`](archive/) directory for reference.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
