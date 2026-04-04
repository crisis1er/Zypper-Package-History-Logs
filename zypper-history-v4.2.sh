#!/bin/bash
# Script: zypper-history.sh
# Version: 4.1 (PROFESSIONAL - Validation + Multi-langue + COULEURS)
# Last Updated: 2025-11-09

set -euo pipefail
IFS=$'\n\t'

# ==================== VERSION INFO ====================
SCRIPT_VERSION="4.2"
SCRIPT_DATE="2026-04-04"
SCRIPT_AUTHOR="SafeITExperts"
SCRIPT_GITHUB="https://github.com/crisis1er/Zypper-Package-History-Logs/tree/main"

# ==================== MULTI-LANGUE MESSAGES ====================
LANG="${LANG:-fr_FR.UTF-8}"

declare -A MSG=(
    [need_root]="⚠️  Ce script nécessite les droits root pour accéder à /var/log/zypp/history"
    [ask_sudo]="Voulez-vous continuer avec sudo ? [O/n]"
    [cancelled]="Annulation."
    [ask_date_prompt]="Voulez-vous spécifier une date ? [O/n]"
    [enter_date]="📅 Entrez la date (YYYY-MM-DD) :"
    [invalid_date]="❌ Format de date invalide. Utilisez YYYY-MM-DD"
    [date_format_error]="❌ Date invalide ou hors limites"
    [ask_output]="Affichage: [T]erminal ou [F]ichier CSV ? [T/f]"
    [csv_exists]="📁 Fichier existe. Remplacer ? [o/N]"
    [csv_created]="✅ Fichier CSV créé avec succès:"
    [csv_path]="📁"
    [csv_size]="Taille:"
    [csv_lines]="Nombre de lignes:"
    [no_data]="Aucune donnée trouvée pour"
    [select_date]="Date sélectionnée:"
    [ask_list_dates]="Voulez-vous voir les jours avec activité zypper ? [O/n]"
    [available_dates]="📅 Jours avec activité zypper :"
    [no_history]="Aucun historique trouvé dans /var/log/zypp/history"
    [commands_title]="COMMANDES ZYPPER (manuelles)"
    [packages_title]="PAQUETS (installation/suppression)"
    [end_history]="Fin de l'historique"
    [search_help]="Pour chercher un paquet: tapez '/' puis le nom, puis 'Entrée'"
    [quit_help]="Pour quitter: tapez 'q'"
    [unknown_option]="Option inconnue:"
    [usage_help]="Utilisez: zypper-history -h pour l'aide"
)

# ==================== COULEURS ANSI ====================
declare -A COLOR=(
    [RESET]="\033[0m"
    [BOLD]="\033[1m"
    [INSTALL]="\033[92m"        # 🟢 Vert - Installation
    [REMOVE]="\033[91m"         # 🔴 Rouge - Suppression
    [REPO_OSS]="\033[94m"       # 🔵 Bleu - repo-oss
    [REPO_UPDATE]="\033[96m"    # 🔷 Cyan - repo-update
    [PACKMAN]="\033[93m"        # 🟡 Jaune - packman
    [DEFAULT]="\033[37m"        # ⚪ Gris - autres
    [COMMAND]="\033[97m"        # Blanc bright - commandes
    [TYPE]="\033[90m"           # Gris foncé - type
)

# Palette cyclique pour les dépôts tiers (attribuée dynamiquement)
REPO_PALETTE=(
    "\033[35m"   # Magenta
    "\033[33m"   # Orange
    "\033[91m"   # Rouge clair
    "\033[95m"   # Magenta clair
    "\033[36m"   # Cyan foncé
    "\033[32m"   # Vert foncé
    "\033[34m"   # Bleu foncé
    "\033[97m"   # Blanc bright
)

# Map dépôt → couleur (construit dynamiquement)
declare -A REPO_COLORS

# ==================== FONCTION: Construire la map dépôt → couleur ====================
build_repo_colors() {
    # Couleurs fixes pour les dépôts connus
    REPO_COLORS["repo-oss"]="${COLOR[REPO_OSS]}"
    REPO_COLORS["repo-update"]="${COLOR[REPO_UPDATE]}"
    REPO_COLORS["packman"]="${COLOR[PACKMAN]}"

    # Attribution dynamique pour tous les autres dépôts
    local idx=0
    while read -r alias; do
        [[ -z "$alias" ]] && continue
        if [[ -z "${REPO_COLORS[$alias]+x}" ]]; then
            REPO_COLORS["$alias"]="${REPO_PALETTE[$((idx % ${#REPO_PALETTE[@]}))]}"
            ((idx++)) || true
        fi
    done < <(zypper repos 2>/dev/null | awk -F'|' 'NR>2 && /^[[:space:]]*[0-9]/ {gsub(/ /,"",$2); if($2!="") print $2}')
}

# ==================== FONCTION: Colorer dépôt ====================
color_depot() {
    local depot=$1
    local color="${REPO_COLORS[$depot]:-${COLOR[DEFAULT]}}"
    echo -e "${color}${depot}${COLOR[RESET]}"
}

# ==================== FONCTION: Colorer action ====================
color_action() {
    local action=$1
    case "$action" in
        "install")
            echo -e "${COLOR[INSTALL]}${COLOR[BOLD]}${action}${COLOR[RESET]}"
            ;;
        "remove")
            echo -e "${COLOR[REMOVE]}${COLOR[BOLD]}${action}${COLOR[RESET]}"
            ;;
        *)
            echo "$action"
            ;;
    esac
}

# ==================== VÉRIFICATION ROOT ====================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "${MSG[need_root]}"
        echo ""
        read -p "${MSG[ask_sudo]} " response
        if [[ "$response" =~ ^[OoYy] ]] || [[ -z "$response" ]]; then
            exec sudo "$0" "$@"
        else
            echo "${MSG[cancelled]}"
            exit 1
        fi
    fi
}

# ==================== VALIDATION DE DATE RENFORCÉE ====================
validate_date_strict() {
    local DATE=$1
    if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "${MSG[invalid_date]}" >&2
        return 1
    fi
    if ! date -d "$DATE" >/dev/null 2>&1; then
        echo "${MSG[date_format_error]}" >&2
        return 1
    fi
    local TODAY=$(date '+%Y-%m-%d')
    if [[ "$DATE" > "$TODAY" ]]; then
        echo "❌ La date ne peut pas être dans le futur (aujourd'hui: $TODAY)" >&2
        return 1
    fi
    return 0
}

# ==================== FUNCTION: Display Help ====================
show_help() {
    cat << 'HELP'
================================================================================
                   ZYPPER-HISTORY - Audit Complet Zypper
================================================================================

📋 DESCRIPTIF
  zypper-history audit professionnel de l'historique Zypper sur openSUSE

🎨 COULEURS & LÉGENDE (Terminal)
  Actions :
    🟢 install (Vert)   = Paquet installé
    🔴 remove  (Rouge)  = Paquet supprimé
  
  Dépôts :
    🔵 repo-oss     (Bleu)    = Officiel openSUSE
    🔷 repo-update  (Cyan)    = Mises à jour
    🟡 packman      (Jaune)   = Communauté
    🟣 home_*       (Magenta) = Custom
    🟠 Tiers        (Orange)  = Microsoft, Mozilla, etc.
    ⚪ Autres       (Gris)    = Non identifiés

================================================================================
HELP
}

# ==================== FUNCTION: Display Version ====================
show_version() {
    cat << VERSION
zypper-history version $SCRIPT_VERSION
Date: $SCRIPT_DATE
Auteur: $SCRIPT_AUTHOR
GitHub: $SCRIPT_GITHUB
VERSION
}

# ==================== FUNCTION: Create CSV ====================
create_csv() {
    local DATE=$1
    local HISTORY_DATA=$2
    local ORIGINAL_USER="${SUDO_USER:-$USER}"
    local AUDIT_DIR="/home/$ORIGINAL_USER/Audits"
    local CSV_FILE="$AUDIT_DIR/zypper-history-${DATE}.csv"
    
    mkdir -p "$AUDIT_DIR"
    chown "$ORIGINAL_USER:$ORIGINAL_USER" "$AUDIT_DIR"
    chmod 0755 "$AUDIT_DIR"
    
    if [[ -f "$CSV_FILE" ]]; then
        read -p "${MSG[csv_exists]} " replace
        if ! [[ "$replace" =~ ^[Oo] ]]; then
            echo "Annulation."
            return
        fi
    fi
    
    echo "Date,Heure,Type,Action,Utilisateur,Paquet,Version,Architecture,Depot,Commande" > "$CSV_FILE"
    
    COMMAND_DATA=$(echo "$HISTORY_DATA" | grep "|command|" || true)
    if [[ -n "$COMMAND_DATA" ]]; then
        echo "$COMMAND_DATA" | awk -F'|' '{
            date = $1; time = substr(date, 12); date = substr(date, 1, 10)
            type = $2; utilisateur = $3; commande = $4
            for (i=5; i<=NF; i++) commande = commande "|" $i
            gsub(/"/, "\"\"", commande)
            printf "%s,%s,%s,,%s,,,,,\"%s\"\n", date, time, type, utilisateur, commande
        }' >> "$CSV_FILE"
    fi
    
    PACKAGE_DATA=$(echo "$HISTORY_DATA" | grep -E "\|install\||\|remove ?\|" || true)
    if [[ -n "$PACKAGE_DATA" ]]; then
        echo "$PACKAGE_DATA" | awk -F'|' '{
            date = $1; time = substr(date, 12); date = substr(date, 1, 10)
            type = "package"; action = $2; gsub(/ /, "", action)
            paquet = $3; version = $4; arch = $5; depot = $7
            printf "%s,%s,%s,%s,,%s,%s,%s,%s,\n", date, time, type, action, paquet, version, arch, depot
        }' >> "$CSV_FILE"
    fi
    
    chown "$ORIGINAL_USER:$ORIGINAL_USER" "$CSV_FILE"
    chmod 0600 "$CSV_FILE"
    
    echo ""
    echo "${MSG[csv_created]}"
    echo "   ${MSG[csv_path]} $CSV_FILE"
    echo "${MSG[csv_size]} $(du -h "$CSV_FILE" | cut -f1)"
    echo "${MSG[csv_lines]} $(wc -l < "$CSV_FILE")"
}

# ==================== TRAITEMENT DES OPTIONS ====================
check_root "$@"
build_repo_colors

if [[ $# -gt 0 ]]; then
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -v|--version) show_version; exit 0 ;;
        *) echo "${MSG[unknown_option]} $1" >&2; exit 1 ;;
    esac
fi

# ==================== FONCTION: Lister les jours disponibles ====================
list_available_dates() {
    if [[ ! -f /var/log/zypp/history ]]; then
        echo "${MSG[no_history]}"
        return
    fi
    echo ""
    echo "${MSG[available_dates]}"
    echo "===================================================================================="
    grep -v '^#' /var/log/zypp/history | \
        awk -F'|' '{print substr($1,1,10)}' | \
        grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | \
        sort -u | \
        while read -r date; do
            nb_actions=$(grep "^${date}" /var/log/zypp/history | grep -cE "\|install\||\|remove ?\|" || true)
            nb_cmds=$(grep "^${date}" /var/log/zypp/history | grep -c "|command|" || true)
            printf "  📅 %-12s  %2d paquet(s) install/supprimé(s)   %2d commande(s)\n" \
                "$date" "$nb_actions" "$nb_cmds"
        done
    echo "===================================================================================="
    echo ""
}

# ==================== MODE INTERACTIF ====================
DATE=""
read -p "${MSG[ask_list_dates]} " show_list
if [[ "$show_list" =~ ^[OoYy] ]] || [[ -z "$show_list" ]]; then
    list_available_dates
fi

read -p "${MSG[ask_date_prompt]} " response
if [[ "$response" =~ ^[OoYy] ]]; then
    read -p "${MSG[enter_date]} " DATE
    validate_date_strict "$DATE" || exit 1
else
    DATE=$(date '+%Y-%m-%d')
fi

# ==================== TRAITEMENT HISTORIQUE ====================
HISTORY_DATA=$(grep "^${DATE}" /var/log/zypp/history 2>/dev/null || true)
[[ -z "$HISTORY_DATA" ]] && echo "${MSG[no_data]} $DATE" && exit 0

# ==================== CHOIX AFFICHAGE ====================
read -p "${MSG[ask_output]} " output_choice
if [[ "$output_choice" =~ ^[Ff] ]]; then
    create_csv "$DATE" "$HISTORY_DATA"
    exit 0
fi

COMMAND_DATA=$(echo "$HISTORY_DATA" | grep "|command|" || true)
PACKAGE_DATA=$(echo "$HISTORY_DATA" | grep -E "\|install\||\|remove ?\|" || true)

# ==================== AFFICHAGE AVEC COULEURS & PAGINATION ====================
{
    echo "${MSG[select_date]} $DATE"
    echo "===================================================================================="
    echo ""

    if [[ -n "$COMMAND_DATA" ]]; then
        echo "${MSG[commands_title]} - $DATE"
        echo "===================================================================================="
        echo "$COMMAND_DATA" | awk -F'|' 'BEGIN { print "Date/Heure          | Type    | Utilisateur        | Commande"; print "=========================================================================="} {heure = $1; type = $2; utilisateur = $3; commande = $4; for (i=5; i<=NF; i++) commande = commande "|" $i; printf "%-20s| %-7s| %-18s| %s\n", heure, type, utilisateur, commande}'
        echo ""
    fi

    if [[ -n "$PACKAGE_DATA" ]]; then
        echo "${MSG[packages_title]} - $DATE"
        echo "===================================================================================="
        echo "$PACKAGE_DATA" | awk -F'|' 'BEGIN { print "Date/Heure          | Action   | Paquet                      | Version      | Arch"} {heure = $1; action = $2; gsub(/ /, "", action); paquet = $3; version = $4; arch = $5; depot = $7; printf "%-20s| %-8s| %-27s| %-12s| %s\n", heure, action, paquet, version, arch; printf "  └─ Dépôt: %s\n", depot}' | while IFS= read -r line; do
            if [[ "$line" =~ "Dépôt:" ]]; then
                depot=$(echo "$line" | sed 's/.*Dépôt: //')
                colored_depot=$(color_depot "$depot")
                echo "$line" | sed "s/Dépôt: .*/Dépôt: $colored_depot/"
            elif [[ "$line" =~ "install" ]]; then
                echo "$line" | sed "s/| install /| $(color_action 'install') /"
            elif [[ "$line" =~ "remove" ]]; then
                echo "$line" | sed "s/| remove /| $(color_action 'remove') /"
            else
                echo "$line"
            fi
        done
        echo ""
    fi

    echo "===================================================================================="
    echo "${MSG[end_history]}"
    echo ""
    echo "${MSG[search_help]}"
    echo "${MSG[quit_help]}"

} | less -R

exit 0
