# Contributing to zypper-history

Thank you for your interest in contributing. Contributions of all kinds are welcome — bug reports, feature suggestions, documentation improvements, and code changes.

---

## Reporting bugs

When filing a bug report, please include:

- **openSUSE version** (Tumbleweed / Leap 15.x)
- **Kernel version** (`uname -r`)
- **Zypper version** (`zypper --version`)
- **Exact command used**
- **Expected behavior**
- **Observed behavior**
- **Relevant log excerpt** if applicable

Open an issue at: https://github.com/crisis1er/Zypper-Package-History-Logs/issues

---

## Suggesting features

Open a discussion or issue describing:

- The use case you want to address
- The proposed behavior
- Any alternative approaches you considered

---

## Submitting pull requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following the code standards below
4. Test on at least one openSUSE version
5. Update `CHANGELOG.md` under a new version entry
6. Submit a pull request with a clear description of the changes

---

## Code standards

- Target **bash 5+** — avoid bashisms that require newer versions
- Use `set -euo pipefail` at the top of scripts
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use meaningful variable names in UPPER_CASE for globals, lower_case for locals
- Add comments for non-obvious logic
- Keep functions focused on a single responsibility
- Test with `bash -n script` before submitting

---

## Contact

For questions or feedback: open a [Discussion](https://github.com/crisis1er/Zypper-Package-History-Logs/discussions)
