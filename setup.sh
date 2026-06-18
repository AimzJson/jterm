#!/bin/bash
# macOS Setup Script
# Run from the cloned repo directory: ./setup.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Packages
echo "Installing packages..."
brew install zsh-autosuggestions fzf zoxide eza bat git-delta lazygit starship
brew install --cask font-geist-mono-nerd-font

# fzf shell integration
echo "Setting up fzf..."
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

# WezTerm config
echo "Setting up WezTerm config..."
mkdir -p "$HOME/.config/wezterm"
cp "$SCRIPT_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Starship config
echo "Setting up starship config..."
mkdir -p "$HOME/.config/starship"
cp "$SCRIPT_DIR/starship.toml" "$HOME/.config/starship/starship.toml"

# Lazygit config
echo "Setting up lazygit config..."
mkdir -p "$HOME/.config/lazygit"
cp "$SCRIPT_DIR/lazygit.yml" "$HOME/.config/lazygit/config.yml"

# Git delta config
echo "Configuring git delta..."
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.paging never
git config --global delta.syntax-theme "Dracula"
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

# zsh config
echo "Setting up zsh config..."
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    echo "Existing .zshrc backed up to ~/.zshrc.backup"
fi
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

echo ""
echo "Setup complete. Run 'source ~/.zshrc' or restart your terminal."
