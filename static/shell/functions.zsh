# Launch ZFVimDirDiff directly from the terminal
function dirdiff() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: dirdiff <project_A> <project_B>"
        return 1
    fi
    lvim -c "ZFDirDiff $1 $2"
}

# Smart Dotfiles Add: Stages files and updates the Whitelist Exclude
function adf() {
    local target="$1"
    local exclude_file="$HOME/.config/git/exclude"

    # Store the command as an array to handle arguments correctly
    local dot_cmd=(/usr/bin/git --git-dir="$HOME/.dotfiles-linux/" --work-tree="$HOME")
    
    # 1. Run the git add using the array expansion
    # The "${dot_cmd[@]}" ensures flags are passed individually
    "${dot_cmd[@]}" add -f "$target"

    # 2. If it's a directory, update the exclude whitelist
    if [[ -d "$target" ]]; then
        local clean_path="${target%/}"
        [[ "$clean_path" != /* ]] && clean_path="/$clean_path"

        local rule="!${clean_path}/"


        if ! grep -Fxq "$rule" "$exclude_file"; then
            echo "$rule" >> "$exclude_file"
            echo "Added $rule to dotfiles whitelist."
        else
            echo "$rule is already whitelisted."
        fi
    fi
}

# Lazygit Wrapper for AGS Title Detection
lazygit() {
  print -n "\e]2;lazygit\a"       # 1. Force Kitty title to 'lazygit'
  command lazygit "$@"            # 2. Launch the ACTUAL lazygit binary with all arguments
  print -n "\e]2;zsh\a"           # 3. Revert title to 'zsh' upon exit
}

# Nuke fasd file aliases
unalias v 2>/dev/null
unalias z 2>/dev/null

# # V fzf direct piper and preview
# v() {
#   # If you just type 'nvim' and press Enter, automatically open fzf
#   if [[ $# -eq 0 ]]; then
# # Define the theme string so the command doesn't become a massive unreadable block
#     local theme="bg+:#363a4f,bg:-1,hl:#ed8796,header:#ed8796,pointer:#ff4852,marker:#b7bdf8,fg+:#cad3f5,hl+:#ed8796,preview-bg:#2c2e34"
#     # Notice the single quotes added around the --preview-window string
#     local files=("${(@f)$(
#      (fasd -Rfl 2>/dev/null; fd --type f --hidden 2>/dev/null) | awk 'seen[$ 0]++ == 0' | \ 
#       fzf --multi --margin="0,2" --color="$theme" --no-height \
#       --preview 'bat --theme="Dracula" --color=always --style=plain {} 2>/dev/null' \
#       --preview-window='right:60%:border-left,<80(down:50%:border-top)')}")
#     # If a file was selected, open it using the ACTUAL nvim binary
#     if [[ ${#files[@]} -gt 0 && -n "${files[1]}" ]]; then
#       # Add them to fasd cache
# fasd -A "${files[@]}" 2>/dev/null
#       command nvim "${files[@]}"
#     fi
#   else
#     # If you type 'nvim filename.txt', bypass fzf completely and just open it
# fasd -A "$@" 2>/dev/null
#     command nvim "$@"
#   fi
# }


# Helper: launch nvim under direnv when the target lives inside a .envrc
# project, so the flake's devShell LSPs/formatters end up on $PATH.
_v_launch() {
  # Add them to fasd cache
  fasd -A "$@" 2>/dev/null

  # Resolve args to absolute paths but DO NOT follow symlinks into the Nix store
  local -a abs_files
  local f
  for f in "$@"; do
    abs_files+=("${f:a}")
  done

  # Walk up from the first file's dir looking for .envrc
  local root="${abs_files[1]:h}"
  local found_envrc=false

  # Allow the loop to check the home directory, but stop at the filesystem root
  while [[ "$root" != "/" ]]; do
    if [[ -f "$root/.envrc" ]]; then
      found_envrc=true
      break
    fi
    root="${root:h}"
  done

  if [[ "$found_envrc" == true ]]; then
    # Subshell: cd to the envrc directory, load direnv, and launch nvim
    # Using 'command nvim' bypasses any aliases to prevent infinite loops
    (cd "$root" && direnv exec . nvim "${abs_files[@]}")
  else
    # No .envrc upstream: fall back to the native binary
    command nvim "${abs_files[@]}"
  fi
}

# V fzf direct piper and preview
v() {
  if [[ $# -eq 0 ]]; then
    local theme="bg+:#363a4f,bg:-1,hl:#ed8796,header:#ed8796,pointer:#ff4852,marker:#b7bdf8,fg+:#cad3f5,hl+:#ed8796,preview-bg:#2c2e34"
    local files=("${(@f)$(
      (fasd -Rfl 2>/dev/null; fd --type f --hidden 2>/dev/null) | awk 'seen[$ 0]++ == 0' | \
      fzf --multi --margin="0,2" --color="$theme" --no-height \
        --preview 'bat --theme="Dracula" --color=always --style=plain {} 2>/dev/null' \
        --preview-window='right:60%:border-left,<80(down:50%:border-top)')}")
    
    if [[ ${#files[@]} -gt 0 && -n "${files[1]}" ]]; then
      _v_launch "${files[@]}"
    fi
  else
    _v_launch "$@"
  fi
}


function fetch-obsidianconfig()() {
    # Configuration
    local REPO_SSH="git@github.com:Paramuno/dotfiles-linux.git"
    local REMOTE_DIR=".config/obsidianconfig"
    local LOCAL_DEST="$HOME/Downloads/obsidianconfig"
    local TEMP_DIR
    TEMP_DIR=$(mktemp -d -t obsidian-dl-XXXXXX)

    echo "--- Initiating Secure SSH Clone ---"

    # 1. Sparse clone using SSH
    # --filter=blob:none avoids downloading file contents until we specify the folder
    if ! git clone --depth 1 --filter=blob:none --sparse "$REPO_SSH" "$TEMP_DIR"; then
        echo "Error: SSH authentication failed. Check your ~/.ssh keys and GitHub settings."
        rm -rf "$TEMP_DIR"
        return 1
    fi

    # 2. Narrow the checkout to only the obsidianconfig folder
    echo "--- Extracting $REMOTE_DIR ---"
    git -C "$TEMP_DIR" sparse-checkout set "$REMOTE_DIR"

    # 3. Prepare the Downloads folder
    if [ -d "$LOCAL_DEST" ]; then
        echo "Note: $LOCAL_DEST already exists. Updating contents..."
    else
        mkdir -p "$LOCAL_DEST"
    fi

    # 4. Copy contents and clean up
    # The /. at the end of the source path ensures we copy contents, not the folder itself
    cp -r "$TEMP_DIR/$REMOTE_DIR/." "$LOCAL_DEST/"
    rm -rf "$TEMP_DIR"

    echo "--- Success ---"
    echo "Files are now located in: $LOCAL_DEST"
}
