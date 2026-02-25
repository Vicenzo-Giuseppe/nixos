{
  pkgs,
  user,
  host,
  enabled,
  lib,
  ...
}: let
in {
  home = {config, ...}: let
    inherit (config.lib) cosmic;
    mkRON = cosmic.mkRON;
  in
    lib.mkIf enabled {
      # Configure COSMIC desktop settings
      wayland.desktopManager.cosmic = {
        enable = true;
        compositor = {
          input_default = {
            click_method = mkRON "optional" (mkRON "enum" "Clickfinger");
            disable_while_typing = mkRON "optional" true;
            acceleration = mkRON "optional" {
              profile = mkRON "optional" (mkRON "enum" "Adaptive");
              speed = 0.5;
            };
            left_handed = mkRON "optional" false;
            middle_button_emulation = mkRON "optional" false;
            scroll_config = mkRON "optional" {
              method = mkRON "optional" (mkRON "enum" "Edge");
              natural_scroll = mkRON "optional" true;
              scroll_factor = mkRON "optional" 0.5;
              scroll_button = mkRON "optional" 2;
            };
          };
        };

        applets.time.settings = {
          military_time = true; # Enable 24-hour time format
          show_date_in_top_panel = true;
          show_seconds = true;
          show_weekday = true;
          first_day_of_week = 0; # Monday
        };
        applets = {
          audio.settings = {
            show_media_controls_in_top_panel = true;
          };

          app-list.settings = {
            enable_drag_source = true;
            favorites = [
              "firefox"
              "com.system76.CosmicFiles"
              "com.system76.CosmicSettings"
              "com.system76.CosmicPlayer"
            ];
            filter_top_levels = cosmic.mkRON "optional" (cosmic.mkRON "enum" "ActiveWorkspace");
          };
        };
      };
      programs = {
        cosmic-applibrary = {
          enable = false;
        };
        cosmic-edit = {
          enable = false;
        };
        cosmic-ext-calculator = {
          enable = false;
        };
        cosmic-ext-ctl = {
          enable = false;
        };
        cosmic-ext-tweaks = {
          enable = false;
        };
        cosmic-files = {
          enable = true;
          settings = {
            desktop = {
              show_content = true;
              show_mounted_drives = true;
              show_trash = false;
            };
            favorites = [
              (cosmic.mkRON "enum" "Home")
              (cosmic.mkRON "enum" {
                variant = "Path";
                value = [config.xdg.userDirs.desktop];
              })
              #(cosmic.mkRON "enum" "Documents")
              (cosmic.mkRON "enum" "Downloads")
              #(cosmic.mkRON "enum" "Music")
              #(cosmic.mkRON "enum" "Pictures")
              (cosmic.mkRON "enum" "Videos")
              (cosmic.mkRON "enum" {
                variant = "Path";
                value = ["/tmp"];
              })
              (cosmic.mkRON "enum" {
                variant = "Path";
                value = ["/home/${user}/${host}.nix"];
              })
            ];
            show_details = false;
            tab = {
              folders_first = true;
              icon_sizes = {
                grid = 100;
                list = 100;
              };
              show_hidden = true;
              view = cosmic.mkRON "enum" "List";
            };
          };
        };
        cosmic-player = {
          enable = false;
        };
        cosmic-store = {
          enable = false;
        };
        cosmic-term = {
          enable = false;
        };
        forecast = {
          enable = false;
        };
        tasks = {
          enable = false;
        };
      };
    };
  nixos = lib.mkIf enabled {
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      xserver.videoDrivers = ["nvidia"];
    };
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.cosmic-protocols];
    };
  };
}
