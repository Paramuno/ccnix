# PATH exports
export PATH="$HOME/.local/bin/:$PATH"
export ANDROID_USER_HOME="$HOME/.local/share/android"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Default Editor
export EDITOR="nvim"
export VISUAL="nvim"

mkdir -p "$(dirname "$HISTFILE")"
# XDG & Zsh Paths
export ZSH="$HOME/.config/oh-my-zsh"
export SVN_CONFIG_DIR="$HOME/.config/subversion"
export HISTFILE="$HOME/.local/state/zsh-history/.zsh_history"
export XDG_CONFIG_HOME="$HOME/.config"
export PYTHONHISTORY="$HOME/.local/state/python/"

# Oh My Zsh cache location fix
export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"

# Load Standalone Home Manager variables (Required for Fedora)
# NixOS handles this natively via PAM, so it safely skips this block.
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
