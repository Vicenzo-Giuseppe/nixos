{
  pkgs,
  lib,
  enabled,
  inputs,
  ...
}:
let
  inherit (inputs) hyprland;
in
{
  home = lib.mkIf enabled {
    wayland.windowManager.hyprland = {
      enable = true;

      package = null;
      portalPackage = null;
      systemd.enable = false;
      xwayland.enable = true;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "warp";
        "$file-manager" = "spacedrive";
        "$browser" = "zen-twilight";
        "$editor" = "zv";
        "$volumeStep" = "10";

        # ── Caelestia Launcher ──
        bindi = [ ];
        env = [
          "LIBVA_DRIVER_NAME,iHD"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ];
        bind = [
          # Window focus
          "Ctrl, left, movefocus, l"
          "Ctrl, right, movefocus, r"
          "Ctrl, up, movefocus, u"
          "Ctrl, down, movefocus, d"

          # Move windows
          "SUPER, left, movewindow, l"
          "SUPER, right, movewindow, r"
          "SUPER, up, movewindow, u"
          "SUPER, down, movewindow, d"

          # Window actions
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 0"
          #"SUPER+Alt, F, fullscreen, 1"
          "SUPER, Space, togglefloating,"
          "SUPER, P, pin"
          "Ctrl+SUPER, Backslash, centerwindow, 1"

          # Window groups
          "SUPER, Comma, togglegroup"
          "SUPER+Alt, Comma, moveoutofgroup"
          "SUPER+Shift, Comma, lockactivegroup, toggle"

          # Go to workspace
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER, 6, workspace, 6"
          "SUPER, 7, workspace, 7"
          "SUPER, 8, workspace, 8"
          "SUPER, 9, workspace, 9"
          "SUPER, 0, workspace, 10"
          "SUPER, mouse_down, workspace, -1"
          "SUPER, mouse_up, workspace, +1"

          # Move window to workspace
          "Shift+Alt, 1, movetoworkspace, 1"
          "Shift+Alt, 2, movetoworkspace, 2"
          "Shift+Alt, 3, movetoworkspace, 3"
          "Shift+Alt, 4, movetoworkspace, 4"
          "Shift+Alt, 5, movetoworkspace, 5"
          "Shift+Alt, 6, movetoworkspace, 6"
          "Shift+Alt, 7, movetoworkspace, 7"
          "Shift+Alt, 8, movetoworkspace, 8"
          "Shift+Alt, 9, movetoworkspace, 9"
          "Shift+Alt, 0, movetoworkspace, 10"
          "Shift+Alt, mouse_down, movetoworkspace, -1"
          "Shift+Alt, mouse_up, movetoworkspace, +1"
          "Shift+Alt, S, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, up, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, down, movetoworkspace, e+0"

          # Apps
          "SUPER, E, exec, $terminal"
          "SUPER, W, exec, $browser"
          "SUPER, T, exec, $file-manager"

          # Screenshot & colour picker
          "Ctrl+Alt, C, exec, hyprpicker -a"
        ];

        binde = [
          # Resize split
          "SUPER, Minus, splitratio, -0.1"
          "SUPER, Equal, splitratio, 0.1"
          # Workspace nav
          "Ctrl+SUPER, right, workspace, +1"
          "Ctrl+SUPER, left, workspace, -1"
          "SUPER, Page_Up, workspace, -1"
          "SUPER, Page_Down, workspace, +1"
          # Move window to adjacent workspace
          "SUPER+Alt, Page_Up, movetoworkspace, -1"
          "SUPER+Alt, Page_Down, movetoworkspace, +1"
          "Ctrl+SUPER+Shift, right, movetoworkspace, +1"
          "Ctrl+SUPER+Shift, left, movetoworkspace, -1"
          # Window group cycle
          "Alt, Tab, cyclenext"
          "Shift+Alt, Tab, cyclenext, prev"
          "Ctrl+Alt, Tab, changegroupactive, f"
          "Ctrl+Shift+Alt, Tab, changegroupactive, b"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindl = [
          # Volume
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "SUPER+Shift, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          # Sleep
          "SUPER+Shift, L, exec, systemctl suspend-then-hibernate"
        ];

        bindle = [
          ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $volumeStep%+"
          ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ $volumeStep%-"
        ];

        bindr = [ ];

        exec-once = [ ];

        input = {
          kb_layout = "br";
          kb_variant = "abnt2";
          touchpad.natural_scroll = true;
        };

        cursor = {
          no_hardware_cursors = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
        };

        animations = {
          enabled = true;
          bezier = "ease,0.4,0.02,0.21,1";
          animation = [
            "windows,1,7,ease"
            "windowsOut,1,7,default,popin 80%"
          ];
        };
      };
    };

    home.packages = with pkgs; [
      hyprland
      wofi
      swaylock-effects
      brightnessctl
      pamixer
      playerctl
      ddcutil
      hyprpicker
      fuzzel
      wireplumber
      pavucontrol
    ];
  };

  nixos = lib.mkIf enabled {
    programs.hyprland = {
      enable = true;
      package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
            user = "greeter";
          };
        };
      };
    };

    # xdg.portal = {
    #   enable = true;
    #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    # };
    # Kernel (good for newer laptops)

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Native Wayland for Electron apps
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_QPA_PLATFORM = "wayland;xcb";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1"; # Fixes invisible cursor on NVIDIA
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
