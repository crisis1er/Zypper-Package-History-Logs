#!/bin/bash
# Script: zypper-history.sh
# Description: Extracts Zypper history for install, remove, and command actions
# Version: 1.1
# Last Updated: 2025-01-27
#
# Changelog:
# - Added support for "command" actions from /var/log/zypp/history

# N'oubliez pas de rendre ce script exécutable avec la commande :
# chmod +x zypper-history-v2.sh

# Commande principale pour extraire les actions install, remove et command
grep -E "\|install\||\|remove ?\||\|command" /var/log/zypp/history | grep "$(date '+%Y-%m-%d')" | awk -F'|' 'BEGIN {
    print "Date/Heure          | Action   | Paquet/Commande              | Version      "
}
{
    printf "%-20s| %-8s| %-28s| %-12s\n", $1, $2, $3, $4
}'
