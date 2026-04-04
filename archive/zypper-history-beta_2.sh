#!/bin/bash
# Script: zypper-log.sh
# Version: 2.2
# Last Updated: 2025-01-29

# Fonction de validation de date
validate_date() {
    if ! date -d "$1" >/dev/null 2>&1; then
        echo "Erreur: Format de date invalide. Utilisez YYYY-MM-DD" >&2
        exit 1
    fi
}

# Mode interactif
if [ $# -eq 0 ]; then
    read -p "Voulez-vous spécifier une date ? [O/n] " response
    if [[ "$response" =~ ^[OoYy] ]]; then
        read -p "📅 Entrez la date (YYYY-MM-DD) : " DATE
        validate_date "$DATE"
    else
        DATE=$(date '+%Y-%m-%d')
    fi
else
    # Gestion des options
    while getopts "d:h" opt; do
        case $opt in
            d) DATE="$OPTARG" ;;
            h) echo "Usage: $0 [-d YYYY-MM-DD]"; exit 0 ;;
            *) echo "Option invalide"; exit 1 ;;
        esac
    done
    validate_date "$DATE"
fi

# Traitement de l'historique Zypper
echo "=================================================================================="
echo "Historique Zypper (/var/log/zypp/history) - $DATE"
echo "=================================================================================="
grep -E "\|install\||\|remove ?\||\|command" /var/log/zypp/history |
grep "^${DATE}" |
awk -F'|' 'BEGIN {
    print "Date/Heure          | Action   | Paquet/Commande              | Version      "
    print "----------------------------------------------------------------------------------"
}
{
    gsub(/ /, "", $2)
    printf "%-20s| %-8s| %-28s| %-12s\n", $1, $2, $3, $4
}'

# Traitement du log Zypper
echo
echo "=================================================================================="
echo "Log d'exécution (/var/log/zypper.log) - $DATE"
echo "=================================================================================="
zypper log | grep "^${DATE}" | awk '
BEGIN {
    print "Heure               | PID     | Commande"
    print "----------------------------------------------------------------------------------"
}
{
    heure = $1 " " $2
    pid = $3
    commande = $5
    for (i=6; i<=NF; i++) commande = commande " " $i

    printf "%-19s | %-7s | %s\n", heure, pid, commande
}'
