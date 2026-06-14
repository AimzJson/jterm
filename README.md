# jterm

![preview](preview.png)

Personal WezTerm terminal config with cross-platform support for macOS and Windows.

## Features

- Forest green theme with custom background
- 2x2 pane grid on startup (65% / 35% split)
- Iosevka Nerd Font
- Status bar with battery, date and time
- Pane navigation and zoom keybindings
- Shell config with prompt, autosuggestions, fzf, eza, zoxide

## Setup

### macOS

```bash
git clone git@github.com:Chamberja/jterm.git
cd jterm
./setup.sh
```

Restart WezTerm after setup.

### Windows

```powershell
git clone git@github.com:Chamberja/jterm.git
cd jterm
.\setup.ps1
```

Restart WezTerm and PowerShell after setup.

## Keybindings

| Key | Action |
|---|---|
| `Cmd/Ctrl+Shift+T` | New tab with 2x2 grid |
| `Cmd/Ctrl+Shift+Arrow` | Navigate panes |
| `Cmd/Ctrl+Shift+Z` | Zoom active pane |

## Shell aliases (macOS)

| Alias | Command |
|---|---|
| `ls` | `eza --icons` |
| `ll` | `eza -l --icons --git` |
| `la` | `eza -la --icons --git` |
| `lt` | `eza --tree --icons --level=2` |
| `z <dir>` | Jump to directory via zoxide |
