# Prompt: ~/dir (branch) ❯
function prompt {
    $esc = [char]27
    $dir = $PWD.Path -replace [regex]::Escape($HOME), '~'

    $branch = ''
    $b = git branch --show-current 2>$null
    if ($LASTEXITCODE -eq 0 -and $b) {
        $branch = " $esc[36m($b)$esc[0m"
    }

    "$esc[32m$dir$esc[0m$branch $esc[32m❯$esc[0m "
}

# eza
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias ls eza -Force -Option AllScope
    function ll { eza -l --icons --git @args }
    function la { eza -la --icons --git @args }
    function lt { eza --tree --icons --level=2 @args }
}

# bat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias cat bat -Force -Option AllScope
}

# Autosuggestions (PSReadLine 2.1+ only — available in pwsh 7, not Windows PowerShell 5.1)
if ((Get-Module PSReadLine).Version -ge [version]'2.1.0') {
    Set-PSReadLineOption -PredictionSource History
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# fzf key bindings via PSFzf
if (Get-Module -ListAvailable -Name PSFzf -ErrorAction SilentlyContinue) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
}
