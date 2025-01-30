## Overview
Command : `zypper-history-beta_2.sh`
is a practical and efficient command-line tool for openSUSE users to analyze their Zypper package management history. This script parses the Zypper history file (/var/log/zypp/history) and provides a clear, formatted summary of actions such as installed, removed packages, and executed commands. It is particularly useful for troubleshooting and auditing system changes.

# Package History
grep -E "\|install\||\|remove ?\||\|command" /var/log/zypp/history | grep "$DATE" | awk -F'|' '{printf "%-20s|%-8s|%-28s|%-12s\n", $1, $2, $3, $4}'

# Command Log
zypper log | grep "^$DATE" | awk '{printf "%-19s | %-7s | ", $1" "$2, $3; for(i=5;i<=NF;i++) printf $i" "}'

## Main Commands

### 1. Package History Extraction
```bash
grep -E "\|install\||\|remove ?\||\|command" /var/log/zypp/history \
| grep "$DATE" \
| awk -F'|' 'BEGIN {print "DateTime|Action|Package/Command|Version"} 
            {gsub(/ /, "", $2); printf "%-20s|%-8s|%-28s|%-12s\n", $1, $2, $3, $4}'

zypper log \
| grep "^$DATE" \
| awk 'BEGIN {print "Time|PID|Command"} 
       {printf "%-19s | %-7s | ", $1" "$2, $3; for(i=5;i<=NF;i++) printf $i" "; print ""}'

## Tools Used

- **`grep`**: Pattern matching in log files (`install`/`remove`/`command` actions)
- **`awk`**: Data formatting and column alignment (custom output presentation)
- **`date`**: Date validation and filtering (supports `YYYY-MM-DD` format)
- **Pipes (`|`)**: Command chaining for data processing workflows
- **Zypper API**: Native integration with `zypper log` for command execution tracking

## Date Format Options
- Current date: `grep $(date '+%Y-%m-%d')`
- Specific date: `grep "2025-01-25"`

## Practical Use Case

### Problem: Limited Troubleshooting Data
YaST history doesn't provide terminal command outputs, which are critical for debugging system changes.

### Solution: Unified Package & Command Audit
This script consolidates essential data from two sources for a specified date:

**From `zypper history`:**
- 🛠️ **Executed commands** (install/remove/package operations)
- 📦 **Installed packages** (name + version)
- 🗑️ **Removed packages** (name + version)

**From `zypper.log`:**
- 📜 **Filtered terminal commands** (user-initiated actions only, excluding internal system logs)

### Key Use Cases
1. **Post-update analysis**  
   Verify exactly what changed during maintenance windows
2. **Security audits**  
   Track package modifications and privileged commands
3. **Debugging regressions**  
   Correlate system issues with specific package versions/operations
4. **Admin handover**  
   Document changes made during specific timeframes

**Example Scenario:**  
_"Why did our service break after January 29th updates?"_  
→ Use `2025-01-29` report to identify:  
   - Suspect packages updated/removed  
   - Relevant zypper commands executed that day

## Contributing

### Share Your Experience!  
This script improves through technical feedback. Your insights on zypper log behavior are valuable!

**How to Contribute:**  
🔧 **Unexpected Behavior?**  
Example:  
_"On 2025-01-29, the command list didn't include my `purge-kernels` call"_  

📦 **Identified Issue?**  
Example:  
_"This script helped me detect:  
- A faulty update  
- A package removed by mistake  
- An unsuitable command for my environment"_  

💡 **Suggested Improvement?**  
Example:  
_"Could we highlight security-related packages in red?"_

**Share via:**  
👉 [GitHub Discussions](https://github.com/crisis1er/Zypper-Package-History-Logs/discussions)  
📁 [Repository](https://github.com/crisis1er/Zypper-Package-History-Logs/tree/main)  
✉️ Email: logistic@ikmail.com  

**Useful Information to Include:**  
- Context: "I was troubleshooting [dependency issues/rollback...]"
- Expected: "I expected to see [specific command/package]"
- Observed Result: "I noticed [abnormal behavior/missing data]"
- Technical Environment: "openSUSE Leap 15.5 - Kernel 6.13.0-1-default - Zypper 1.14.81"

## License
[MIT]

