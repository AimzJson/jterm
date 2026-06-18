export PATH="$HOME/.local/bin:$PATH"
export LESS="-FRX"

# Prompt
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:git:*' formats ' %F{cyan}(%b)%f'
setopt PROMPT_SUBST
PROMPT='%F{green}%~%f${vcs_info_msg_0_} %F{green}❯%f '

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*' menu select                     # arrow-key menu

# zsh-autosuggestions
if [ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# fzf
if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

# Report CWD to WezTerm
function _report_cwd() {
  printf '\033]7;file://%s%s\033\\' "$HOST" "$PWD"
}
add-zsh-hook chpwd _report_cwd
_report_cwd

# eza
if command -v eza &>/dev/null; then
  alias ls="eza --icons"
  alias ll="eza -l --icons --git"
  alias la="eza -la --icons --git"
  alias lt="eza --tree --icons --level=2"
fi

# zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# bat
if command -v bat &>/dev/null; then
  alias cat="bat --paging=never"
fi
