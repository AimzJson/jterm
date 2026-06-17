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

# PSFzf module
Write-Host "Installing PSFzf PowerShell module..."
try {
    Install-Module PSFzf -Scope CurrentUser -Force
    Write-Host "PSFzf installed."
} catch {
    Write-Host "PSFzf install failed. Run manually: Install-Module PSFzf -Scope CurrentUser"
}

Write-Host ""
Write-Host "Setup complete. Restart WezTerm and PowerShell to apply changes."
