# Zellij
alias zj="zellij"
alias za="zellij attach -c"

# To call bare sidecar repository for .config as suggested here - https://gemini.google.com/app/6ea86f370e8df057
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles-linux/ --work-tree=$HOME'

# Lazygit nix home
alias lh="lazygit -p ~/.config/home-manager"
alias ca="cd ~/.config/home-manager/ && colmena apply"
alias co="cd ~/.config/home-manager/ && colmena apply --on"

# We use a full function also called adf
# To use lazygit to manage config
alias ldf='lazygit --git-dir=$HOME/.dotfiles-linux/ --work-tree=$HOME'

# Quicker nmapplet on fedora
alias wifi='nm-applet'

# Repomix make context for nix hm repo
alias rn="cd ~/.config/home-manager/ && nix run nixpkgs#repomix"

# Hypr wake remote
alias hypr-wake="env HYPRLAND_INSTANCE_SIGNATURE=$(basename $(dirname $(find /run/user/$(id -u)/hypr -maxdepth 2 -name ".socket.sock" -print -quit))) hyprctl dispatch dpms on"
alias hypr-sleep="env HYPRLAND_INSTANCE_SIGNATURE=$(basename $(dirname $(find /run/user/$(id -u)/hypr -maxdepth 2 -name ".socket.sock" -print -quit))) hyprctl dispatch dpms off"
