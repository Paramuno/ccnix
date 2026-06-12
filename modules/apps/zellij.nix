{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.myModules.apps.zellij.enable = lib.mkEnableOption "zellij";

  config = lib.mkIf config.myModules.apps.zellij.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      enableFishIntegration = false;
      enableBashIntegration = false;
    };

    xdg.configFile."zellij/config.kdl".source = ../../static/zellij/config.kdl;

    xdg.configFile."zellij/layouts/zjstatus.kdl".text =
      # kdl
      ''
        layout {
          default_tab_template {
            floating_panes {
              pane height=1 width=28 x="100%" y="0" borderless=true pinned=true {
              // pane height=8 width=50 x="100%" y="0" borderless=false pinned=true {
                // Dynamically inject the path to the wasm binary directly from the flake input
                  plugin location="file:${
                    inputs.zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default
                  }/bin/zjstatus.wasm" {
                  format_left   ""
                  format_center ""
                  format_right  "{tabs} {mode}#[bg=#373273,fg=#89b4fa,bold] {session}#[fg=#373273,bg=#262626]"
                  format_space  ""
                  format_hide_on_overlength "false"
                  format_precedence "crl"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[fg=#6C7086]{char}"
                  border_position "top"

                  mode_normal       "#[bg=#262626,fg=#373273]#[bg=#373273,fg=#181926,bold]🐕"
                  mode_locked       "#[bg=#262626,fg=#181926]#[fg=#9ea4c8,bg=#181926,bold] "
                  mode_resize       "#[bg=#262626,fg=#f38ba8]#[bg=#f38ba8,fg=#181926,bold]󰩨 "
                  mode_pane         "#[bg=#262626,fg=#89b4fa]#[bg=#89b4fa,fg=#181926,bold]󱇙 "
                  mode_tab          "#[bg=#262626,fg=#b4befe]#[bg=#b4befe,fg=#181926,bold]󰓩 "
                  mode_scroll       "#[bg=#262626,fg=#f9e2af]#[bg=#f9e2af,fg=#181926,bold]󰬬 "
                  mode_enter_search "#[bg=#262626,fg=#8aadf4]#[bg=#8aadf4,fg=#181926,bold]󱁵 E"
                  mode_search       "#[bg=#262626,fg=#8aadf4]#[bg=#8aadf4,fg=#181926,bold]󱁵 "
                  mode_rename_tab   "#[bg=#262626,fg=#b4befe]#[bg=#b4befe,fg=#181926,bold]󰓩 R"
                  mode_rename_pane  "#[bg=#262626,fg=#89b4fa]#[bg=#89b4fa,fg=#181926,bold]󱇙 R"
                  mode_session      "#[bg=#262626,fg=#74c7ec]#[bg=#74c7ec,fg=#181926,bold] "
                  mode_move         "#[bg=#262626,fg=#f5c2e7]#[bg=#f5c2e7,fg=#181926,bold]󰆾 "
                  mode_prompt       "#[bg=#262626,fg=#8aadf4]#[bg=#8aadf4,fg=#181926,bold]󰽐 "
                  mode_tmux         "#[bg=#262626,fg=#f5a97f]#[bg=#f5a97f,fg=#181926,bold]TMUX"

                  tab_normal              "#[fg=#6C7086]{name}"
                  tab_normal_fullscreen   "#[fg=#6C7086]{name}"
                  tab_normal_sync         "#[fg=#6C7086]{name}"

                  // formatting for the current active tab
                  tab_active              "#[fg=#89b4fa,bold]{name}#[fg=yellow,bold]{floating_indicator}"
                  tab_active_fullscreen   "#[fg=yellow,bold]{name}#[fg=yellow,bold]{fullscreen_indicator}"
                  tab_active_sync         "#[fg=green,bold]{name}#[fg=yellow,bold]{sync_indicator}"

                  tab_separator    "#[fg=cyan,bold]"

                  // indicators
                  tab_sync_indicator       " "
                  tab_fullscreen_indicator " 󰊓"
                  tab_floating_indicator   ""
                  //tab_floating_indicator   " 󰹙"

                  command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                  command_git_branch_format      "#[fg=blue] {stdout} "
                  command_git_branch_interval    "10"
                  command_git_branch_rendermode  "static"

                  datetime        "#[fg=#6C7086,bold] {format} "
                  datetime_format "%A, %d %b %Y %H:%M"
                  datetime_timezone "Europe/London"
                  }
              }
          }
              children
          }
          tab name=" 󰲠 " focus=true borderless=true
          tab name=" 󰲢 "
          tab name=" 󰲤 "

          swap_tiled_layout name="vertical" {
              tab max_panes=5 {
                  pane split_direction="vertical" {
                      pane
                      pane { children; }
                  }
              }
              tab max_panes=8 {
                  pane split_direction="vertical" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                  }
              }
          }

          swap_tiled_layout name="horizontal" {
              tab max_panes=5 {
                  pane split_direction="horizontal" {
                      pane
                      pane { children; }
                  }
              }
              tab max_panes=8 {
                  pane split_direction="horizontal" {
                      pane { children; }
                      pane { pane; pane; pane; pane; }
                  }
              }
            }

          }
      '';
  };
}
