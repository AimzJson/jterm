# WezTerm Windows Setup
# Run from the cloned repo directory: .\setup.ps1

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# WezTerm config
Write-Host "Setting up WezTerm config..."
$configDir = "$env:USERPROFILE\.config\wezterm"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
Copy-Item "$scriptDir\wezterm.lua" "$configDir\wezterm.lua" -Force
Write-Host "WezTerm config copied to $configDir"

# PowerShell profile
Write-Host "Setting up PowerShell profile..."
$profileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
Copy-Item "$scriptDir\profile.ps1" $PROFILE -Force
Write-Host "PowerShell profile copied to $PROFILE"

# Starship config
Write-Host "Setting up starship config..."
$starshipDir = "$env:USERPROFILE\.config\starship"
New-Item -ItemType Directory -Force -Path $starshipDir | Out-Null
Copy-Item "$scriptDir\starship.toml" "$starshipDir\starship.toml" -Force

# Lazygit config
Write-Host "Setting up lazygit config..."
$lazygitDir = "$env:USERPROFILE\.config\lazygit"
New-Item -ItemType Directory -Force -Path $lazygitDir | Out-Null
Copy-Item "$scriptDir\lazygit.yml" "$lazygitDir\config.yml" -Force

# Geist Mono Nerd Font
Write-Host "Installing Geist Mono Nerd Font..."
try {
    winget install DEVCOM.GeistMonoNerdFont --silent --accept-package-agreements --accept-source-agreements
    Write-Host "Geist Mono Nerd Font installed."
} catch {
    Write-Host "winget install failed. Download Geist Mono Nerd Font manually from:"
    Write-Host "https://www.nerdfonts.com/font-downloads"
}

# fzf
Write-Host "Installing fzf..."
try {
    winget install junegunn.fzf --silent --accept-package-agreements --accept-source-agreements
    Write-Host "fzf installed."
} catch {
    Write-Host "fzf install failed. Download manually from https://github.com/junegunn/fzf/releases"
}

# eza
Write-Host "Installing eza..."
try {
    winget install eza-community.eza --silent --accept-package-agreements --accept-source-agreements
    Write-Host "eza installed."
} catch {
    Write-Host "eza install failed. Download manually from https://github.com/eza-community/eza/releases"
}

# zoxide
Write-Host "Installing zoxide..."
try {
    winget install ajeetdsouza.zoxide --silent --accept-package-agreements --accept-source-agreements
    Write-Host "zoxide installed."
} catch {
    Write-Host "zoxide install failed. Download manually from https://github.com/ajeetdsouza/zoxide/releases"
}

# bat
Write-Host "Installing bat..."
try {
    winget install sharkdp.bat --silent --accept-package-agreements --accept-source-agreements
    Write-Host "bat installed."
} catch {
    Write-Host "bat install failed. Download manually from https://github.com/sharkdp/bat/releases"
}

# delta
Write-Host "Installing delta..."
try {
    winget install dandavison.delta --silent --accept-package-agreements --accept-source-agreements
    Write-Host "delta installed."
} catch {
    Write-Host "delta install failed. Download manually from https://github.com/dandavison/delta/releases"
}

# lazygit
Write-Host "Installing lazygit..."
try {
    winget install JesseDuffield.lazygit --silent --accept-package-agreements --accept-source-agreements
    Write-Host "lazygit installed."
} catch {
    Write-Host "lazygit install failed. Download manually from https://github.com/jesseduffield/lazygit/releases"
}

# starship
Write-Host "Installing starship..."
try {
    winget install Starship.Starship --silent --accept-package-agreements --accept-source-agreements
    Write-Host "starship installed."
} catch {
    Write-Host "starship install failed. Download manually from https://starship.rs"
}

# PSFzf module
Write-Host "Installing PSFzf PowerShell module..."
try {
    Install-Module PSFzf -Scope CurrentUser -Force
    Write-Host "PSFzf installed."
} catch {
    Write-Host "PSFzf install failed. Run manually: Install-Module PSFzf -Scope CurrentUser"
}

# Git delta config
Write-Host "Configuring git delta..."
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.paging never
git config --global delta.syntax-theme "Dracula"
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

Write-Host ""
Write-Host "Setup complete. Restart WezTerm and PowerShell to apply changes."
