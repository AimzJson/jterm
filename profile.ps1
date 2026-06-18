# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# eza
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias ls eza
    function ll { eza -l --icons --git @args }
    function la { eza -la --icons --git @args }
    function lt { eza --tree --icons --level=2 @args }
}

# bat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

# Autosuggestions (built into PSReadLine)
Set-PSReadLineOption -PredictionSource History

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# fzf key bindings via PSFzf
if (Get-Module -ListAvailable -Name PSFzf -ErrorAction SilentlyContinue) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
}
