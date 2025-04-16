# Contributing

We welcome contributions! Please fork the repository and submit a pull request.


## Local Developer Setup

To contribute and test this GitHub Action locally, follow the setup guide below for your OS.

### Requirements
- Python 3.7+
- `pre-commit`
- `jq`, `yq` (YAML/JSON tools)
- `gh` (GitHub CLI)
- GPG (with optional YubiKey integration)
- Git (with GPG support)

---

### Linux (Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y python3-pip jq yq gh gnupg2
pip3 install pre-commit
pre-commit install
```

---

### macOS (Homebrew)

```bash
brew install jq yq gh gnupg
pip3 install pre-commit
pre-commit install
```

---

### Windows (WSL recommended)

```bash
# In WSL (Ubuntu)
sudo apt update
sudo apt install -y python3-pip jq yq gh gnupg2
pip3 install pre-commit
pre-commit install
```

If using native Windows, install the tools via Chocolatey or GitHub CLI installers:
- [GitHub CLI](https://cli.github.com/)
- [GnuPG](https://gpg4win.org/)
- [Python](https://www.python.org/)

---

### Signing Commits with GPG

Ensure your Git is configured to sign commits by default:

```bash
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_KEY_ID
```

To check setup:
```bash
gpg --card-status
gpg --list-secret-keys --keyid-format LONG
```

You can link your public key here: [https://github.com/settings/keys](https://github.com/settings/keys)

---

### Running Pre-commit Locally

To run all pre-commit hooks on staged files:
```bash
pre-commit run
```

To scan all files:
```bash
pre-commit run --all-files
```

---

Happy contributing!
