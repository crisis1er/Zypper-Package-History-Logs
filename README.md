## Overview
Command : `zypper-history-v2.sh`
is a practical and efficient command-line tool for openSUSE users to analyze their Zypper package management history. This script parses the Zypper history file (/var/log/zypp/history) and provides a clear, formatted summary of actions such as installed, removed packages, and executed commands. It is particularly useful for troubleshooting and auditing system changes.

## Command
grep -E "\|install\||\|remove ?\||\|command" /var/log/zypp/history | grep "$(date '+%Y-%m-%d')" | awk -F'|' 'BEGIN {print "Date/Heure          | Action   | Paquet/Commande              | Version      "}
{printf "%-20s| %-8s| %-28s| %-12s\n", $1, $2, $3, $4}'


## Sample Output
Date/Heure          | Action   | Paquet/Commande              | Version      
2025-01-27 00:22:15 | command | root@unixlinuxpro           | 'zypper' 'dup'

2025-01-27 00:25:03 | remove  | ovpn-dco-kmp-default        | 0.2.20241216~git0.a08b2fd_k6.13.0_1-1.22

2025-01-27 00:25:43 | install | chromium                    | 132.0.6834.110-1.1

2025-01-27 00:25:51 | install | libQt6Bluetooth6            | 6.8.1-3.1   

## Tools Used
- **grep**: Searches for specific patterns in the history file
- **awk**: Formats the extracted data (titles and columns)
- **date**: Obtains date in desired format
- **Pipes (|)**: Chains commands together

## Date Format Options
- Current date: `grep $(date '+%Y-%m-%d')`
- Specific date: `grep "2025-01-25"`

## Practical Use Case
This tool is particularly useful for troubleshooting. For example, if OpenVPN stops working after an update, the command can reveal that a module or dependency was removed:

Date/Heure | Action | Paquet | Version
2025-01-27 00:25:03 | remove | ovpn-dco-kmp-default | 0.2.20241216~git0.a08b2fd_k6.13.0_1-1.22


## Contributing
Feel free to submit issues and enhancement requests!

## License
[MIT]

