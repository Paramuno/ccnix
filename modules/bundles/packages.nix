# for pkgs with minimal or no config files - # Goes everywhere
{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.nix-claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default # llm agent cli
    anydesk # remote working
    ast-grep # grep
    bat # cat w highlights & more
    btop # resource monitor
    colmena # nix deployment orchestration
    calibre # brings ebook covert cmd
    chafa # ASCII terminal graphics
    dysk # disk utilization viewer
    fasd # pipe frecency into fzf file widget results
    fd # Find command
    fish # shell
    gcc # Compiler dependecy
    hyprshot # Screenshot service
    imagemagick # terminal images
    jq # json parser
    pandoc # text convert cmd
    ripgrep # fuzzy search
    sshfs # mounting remote dirs over ssh
    tailscale # ssh virtual network aliaser
    trash-cli # safe trash
    unzip # zip
    wev # wayland event debugger
    wget # dl over https/fp
    wl-clipboard # Clipboard for nvim
    zoxide # Z cd command
    yt-dlp # mpv dependency
    zsh-autocomplete # zsh shell plugin
    as-tree # for making automatic folder trees w fd
    statix # so nvim stops complaining
    gh # github CLI

    # (writeShellScriptBin "forgecode" ''
    #   # LLM Harness open to try with Gemini Flash
    #   export PATH="${nodejs}/bin:$PATH"
    #   exec npx forgecode@latest "$@"
    # '')

    # typography
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
  ];
}
