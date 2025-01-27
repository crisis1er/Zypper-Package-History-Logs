#!/bin/bash
grep -E "\|install\||\|remove" /var/log/zypp/history | grep "$(date '+%Y-%m-%d')" | awk -F'|' 'BEGIN {print "Date/Heure          | Action   | Paquet                       | Version      "}
{printf "%-20s| %-8s| %-28s| %-12s\n", $1, $2, $3, $4}'
