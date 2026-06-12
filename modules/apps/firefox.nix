{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.myModules.apps.firefox.enable = lib.mkEnableOption "firefox";
  config = lib.mkIf config.myModules.apps.firefox.enable {
    programs.firefox = {
      enable = true;
      # configPath = "${config.xdg.configHome}/mozilla/firefox";
      configPath = ".mozilla/firefox";
      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "extensions.autoDisableScopes" = 0;
          "browser.startup.homepage" = "about:newtab";
          "browser.tabs.warnOnClose" = false;
          "extensions.webextensions.restrictedDomains" = "";
          "widget.use-xdg-desktop-portal.file-picker" = 1; # yazi portal picker
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable custom stylesheets
          "browser.tabs.inTitlebar" = 1; # firefox must use it's own titlebar to be targeteable by css
          "browser.tabs.drawInTitlebar" = true;
          "signon.rememberSignons" = false; # no password remember prompt
          "ui.key.menuAccessKeyFocuses" = false; # remove alt menu focus
          "browser.download.folderList" = 2; # 0 desktop | 1 system downloads | 2 custom location
          "browser.download.dir" = "${config.home.homeDirectory}/Downloads";
          "browser.quitShortcut.disabled" = true; # no <C-q> to quit
        };
        search = {
          force = true;
          default = "google";
          engines = {
            "Gemini" = {
              urls = [
                {
                  template = "https://gemini.google.com/app?q={searchTerms}";
                }
              ];
              icon = "https://gstatic.com/images/branding/product/1x/gemini_48dp.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@g" ];
            };
            "Nix Packages" = {
              # another search engine example
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
          };
        };
        userChrome = ''
          /* Hide the Minimize, Maximize, and Close buttons */
          .titlebar-buttonbox-container {
            display: none !important;
          }
          /* Optional: Also hide the space they leave behind in the nav-bar */
          #nav-bar .titlebar-buttonbox-container {
            display: none !important;
          }
          /* Optional: If using tabs in titlebar, remove the extra padding on the right */
          .titlebar-spacer[type="post-tabs"] {
            display: none !important;
          }
        '';
        extensions.packages =
          with pkgs.nur.repos.rycee.firefox-addons;
          [
            vimium-c
            darkreader
            violentmonkey
            bitwarden
            onetab
            reddit-enhancement-suite
            copy-as-markdown
            ublock-origin
            videospeed
          ]
          ++ [
            (buildFirefoxXpiAddon {
              pname = "gemini-url-search";
              version = "1.0";
              addonId = "gemini-search@felix-krueckel.com";
              url = "https://addons.mozilla.org/firefox/downloads/file/4696808/gemini_url_search-1.0.xpi";
              sha256 = "0lk5bn1s07ns7skqshcq32k0slbz52mciry48g1zhb31fkw70gvj";
              meta = with pkgs.lib; {
                description = "Search with Gemini from the URL bar";
                license = licenses.unfree;
                platforms = platforms.all;
              };
            })
            (buildFirefoxXpiAddon {
              pname = "nonstop-vimium";
              version = "0.0.7"; # Verify current version
              addonId = "nonstop-vimium-c@example.com";
              url = "https://addons.mozilla.org/firefox/downloads/file/4744068/nonstop_vimium-0.0.7.xpi";
              sha256 = "0kid50hg2919m75647nrviqfka0kds9wcx9dpdjdxz502pqsr222";
              meta = with pkgs.lib; {
                description = "Makes Vimium C work in the PDF view on Firefox.";
                license = licenses.unfree;
                platforms = platforms.all;
              };
            })
          ];
      };
    };
  };
}
