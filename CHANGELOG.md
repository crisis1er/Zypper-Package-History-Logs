# Changelog

## Version 2.0 (2025-01-27)
- Extended the script to include "command" actions from /var/log/zypp/history.
- This captures additional Zypper commands like "zypper refresh", "zypper up","zypper dup"....
- Ensures a complete view of Zypper activity, including install, remove, and command actions.
- Adjusted the regular expression to handle the new action type.

## Version 4.2 (2026-04-04)
- Ajout : liste des jours avec activité zypper avant la saisie de date (nombre de paquets et commandes par jour)
- Amélioration : couleurs des dépôts attribuées dynamiquement via `zypper repos` (palette cyclique)
- Les dépôts repo-oss, repo-update et packman conservent leurs couleurs fixes
- Fonctionne avec n'importe quelle configuration de dépôts utilisateur
- Correction : gestion des lignes vides dans le parsing zypper repos
