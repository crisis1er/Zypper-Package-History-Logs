# Changelog

## Version 2.0 (2025-01-27)
- Extended the script to include "command" actions from /var/log/zypp/history.
- This captures additional Zypper commands like "zypper refresh", "zypper up","zypper dup"....
- Ensures a complete view of Zypper activity, including install, remove, and command actions.
- Adjusted the regular expression to handle the new action type.
