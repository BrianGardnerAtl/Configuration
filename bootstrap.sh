#!/bin/bash
# Bootstrap script for setting up a new Mac development environment.
# Run this from macOS Terminal.app on a fresh machine:
#
#   curl -o bootstrap.sh https://raw.githubusercontent.com/BrianGardnerAtl/Configuration/master/bootstrap.sh
#   bash bootstrap.sh

set -e

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "\n${GREEN}==>${NC} $1"; }
warn()  { echo -e "${YELLOW}WARNING:${NC} $1"; }
action(){ echo -e "\n${BLUE}ACTION REQUIRED:${NC} $1"; }
pause() { read -p "Press Enter to continue..."; }

CONFIG_DIR="$HOME/Development/Configuration"
REPO_URL="git@github.com:BrianGardnerAtl/Configuration.git"
SSH_KEY="$HOME/.ssh/id_ed25519"

# ============================================================
# STEP 1: Homebrew
# ============================================================
log "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH (Apple Silicon installs to /opt/homebrew)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

log "Homebrew ready."

# ============================================================
# STEP 2: Git (needed before cloning the repo)
# ============================================================
log "Installing git..."
brew install git

# ============================================================
# STEP 3: SSH Key (auth + signing)
# ============================================================
log "Checking SSH key..."
if [[ ! -f "$SSH_KEY" ]]; then
    read -p "Enter your GitHub email address: " github_email
    ssh-keygen -t ed25519 -C "$github_email" -f "$SSH_KEY" -N ""
    log "SSH key generated."
fi

# Add key to agent
eval "$(ssh-agent -s)" &>/dev/null
ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY"

action "Add your SSH key to GitHub as BOTH an Authentication key and a Signing key.

  1. Go to: https://github.com/settings/ssh/new
  2. Title: your machine name
  3. Key type: Authentication Key
  4. Paste the key below, then click Add SSH key.

  5. Go to: https://github.com/settings/ssh/new again
  6. Same title, Key type: Signing Key
  7. Paste the same key again.

Your public key:"
echo ""
cat "${SSH_KEY}.pub"
echo ""
pause

# Verify GitHub connection before trying to clone
log "Verifying GitHub SSH connection..."
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    warn "Could not verify GitHub SSH connection. Make sure the key was added before continuing."
    pause
fi

# ============================================================
# STEP 4: Git global config
# ============================================================
log "Configuring git..."
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
    read -p "Your full name for git commits: " git_name
    git config --global user.name "$git_name"
fi
if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
    read -p "Your email for git commits: " git_email
    git config --global user.email "$git_email"
fi

# Configure SSH commit signing
git config --global gpg.format ssh
git config --global user.signingkey "$SSH_KEY"
git config --global commit.gpgsign true
log "Git configured with SSH commit signing."

# ============================================================
# STEP 5: Clone config repo
# ============================================================
if [[ ! -d "$CONFIG_DIR" ]]; then
    log "Cloning configuration repo..."
    mkdir -p "$HOME/Development"
    git clone "$REPO_URL" "$CONFIG_DIR"
else
    log "Config repo already at $CONFIG_DIR — skipping clone."
fi

# ============================================================
# STEP 6: Install all apps via Brewfile
# ============================================================
log "Installing apps and tools via Homebrew..."

# Divvy requires Rosetta 2 on Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
    log "Apple Silicon detected — installing Rosetta 2 for Divvy..."
    softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
fi

brew bundle --file="$CONFIG_DIR/Brewfile"

# Link Java 21 so the system can find it
log "Linking Java 21..."
sudo ln -sfn "$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk" \
    /Library/Java/JavaVirtualMachines/openjdk-21.jdk 2>/dev/null || true

# ============================================================
# STEP 7: oh-my-zsh
# ============================================================
log "Checking for oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    log "oh-my-zsh already installed."
fi

# ============================================================
# STEP 8: Symlinks
# ============================================================
log "Setting up symlinks..."

setup_symlink() {
    local src="$1"
    local dest="$2"
    if [[ -L "$dest" ]]; then
        log "Symlink already exists: $dest"
    else
        [[ -e "$dest" ]] && mv "$dest" "${dest}.bak" && warn "Backed up existing $dest to ${dest}.bak"
        ln -s "$src" "$dest"
        log "Linked $dest -> $src"
    fi
}

setup_symlink "$CONFIG_DIR/zsh_config"        "$HOME/.zshrc"
setup_symlink "$CONFIG_DIR/vim"              "$HOME/.vim"
setup_symlink "$CONFIG_DIR/vim/vimrc"        "$HOME/.vimrc"

# Global agent guidance
mkdir -p "$HOME/.codex" "$HOME/.claude"
setup_symlink "$CONFIG_DIR/codex/AGENTS.md"   "$HOME/.codex/AGENTS.md"
setup_symlink "$CONFIG_DIR/claude/CLAUDE.md"  "$HOME/.claude/CLAUDE.md"

# Claude Code global config
setup_symlink "$CONFIG_DIR/claude/commands"   "$HOME/.claude/commands"
setup_symlink "$CONFIG_DIR/claude/skills"     "$HOME/.claude/skills"

# Claude Code status line — merge into settings.json (preserves existing keys)
SETTINGS="$HOME/.claude/settings.json"
[[ ! -f "$SETTINGS" ]] && echo '{}' > "$SETTINGS"
chmod +x "$CONFIG_DIR/claude/statusline.sh"
jq --arg cmd "$CONFIG_DIR/claude/statusline.sh" \
    '. + {"statusLine": {"type": "command", "command": $cmd, "padding": 1}}' \
    "$SETTINGS" > /tmp/claude_settings.json && mv /tmp/claude_settings.json "$SETTINGS"
log "Status line configured."

# ============================================================
# STEP 9: Vim plugins (Vundle)
# ============================================================
log "Checking Vundle..."
if [[ ! -d "$CONFIG_DIR/vim/bundle/Vundle.vim" ]]; then
    log "Installing Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim.git \
        "$CONFIG_DIR/vim/bundle/Vundle.vim"
fi

log "Installing vim plugins (this may take a moment)..."
vim +PluginInstall +qall 2>/dev/null || warn "vim plugin install had errors — open vim and run :PluginInstall manually if needed."

# ============================================================
# Done
# ============================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Bootstrap complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Remaining manual steps:"
echo ""
echo "  1. iTerm2: Import the color scheme"
echo "       Preferences > Profiles > Colors > Color Presets > Import"
echo "       File: $CONFIG_DIR/material-ocean.itermcolors"
echo ""
echo "  2. Alfred: Enter your license and set up preferences"
echo ""
echo "  3. JetBrains Toolbox: Open and install desired IDEs (e.g. IntelliJ, Android Studio)"
echo ""
echo "  4. Android Studio: Open and complete the SDK setup wizard"
echo ""
echo "  5. Divvy: Open from Applications and configure window layouts"
echo ""
echo "  6. Sign in to Claude Code:"
echo "       claude"
echo ""
echo "  Reload your shell to pick up the new .zshrc:"
echo "       source ~/.zshrc"
echo ""
