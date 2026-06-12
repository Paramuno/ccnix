# # FZF Integration
# source /usr/share/fzf/shell/completion.zsh 2> /dev/null
# source /usr/share/fzf/shell/key-bindings.zsh 2> /dev/null

# Disable Ctrl S and Ctrl Q
stty -ixon
stty eof '^Q'
# This was indirectly making Alt-l
bindkey -r '^[l'

# Ctrl+D for fzf directory and restore Ctrl+T to its default Zsh behavior
bindkey '^D' fzf-file-widget
bindkey '^T' transpose-chars

# Bind Ctrl S for fzf our command history this is set declaratively after loading the fzf fzf-history-widget
# bindkey '^S' fzf-history-widget

# Bind Ctrl Q to what previously Ctrl D did
bindkey '^Q' delete-char-or-list

# Prompt & Navigation
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Package Managers & Runtimes, run only on Fedora
if (( $+commands[brew])); then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Check if file exists before sourcing it
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
