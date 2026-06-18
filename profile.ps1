# Prompt: ~/dir (branch) ❯
function prompt {
    $dir = $PWD.Path -replace [regex]::Escape($HOME), '~'

    $branch = ''
    $b = git branch --show-current 2>$null
    if ($LASTEXITCODE -eq 0 -and $b) {
        $branch = " `e[36m($b)`e[0m"
    }

    "`e[32m$dir`e[0m$branch `e[32m❯`e[0m "
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
