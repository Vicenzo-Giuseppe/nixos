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
          # Window focus (directional + stack cycle)
          "SUPER, H, movefocus, l"
          "SUPER, L, movefocus, r"
          "SUPER, K, movefocus, u"
          "SUPER, J, movefocus, d"
          "SUPER, S, cyclenext"
          "SUPER, D, cyclenext, prev"

          # Move windows
          "SUPER+Shift, H, movewindow, l"
          "SUPER+Shift, L, movewindow, r"
          "SUPER+Shift, K, movewindow, u"
          "SUPER+Shift, J, movewindow, d"

          # Window actions
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 0"
          "SUPER, Space, togglesplit"
          "SUPER+Shift, Space, togglefloating,"
          "SUPER, P, pin"
          "Ctrl+SUPER, Backslash, centerwindow, 1"

          # Window groups
          "SUPER, Comma, togglegroup"
          "SUPER+Alt, Comma, moveoutofgroup"
          "SUPER+Shift, Comma, lockactivegroup, toggle"

          # Go to workspace
          "SUPER, Tab, workspace, +1"
          "SUPER+Ctrl, Tab, workspace, -1"
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
          "SUPER+Shift, Tab, movetoworkspace, +1"
          "SUPER+Ctrl+Shift, Tab, movetoworkspace, -1"
          "SUPER+Shift, 1, movetoworkspace, 1"
          "SUPER+Shift, 2, movetoworkspace, 2"
          "SUPER+Shift, 3, movetoworkspace, 3"
          "SUPER+Shift, 4, movetoworkspace, 4"
          "SUPER+Shift, 5, movetoworkspace, 5"
          "SUPER+Shift, 6, movetoworkspace, 6"
          "SUPER+Shift, 7, movetoworkspace, 7"
          "SUPER+Shift, 8, movetoworkspace, 8"
          "SUPER+Shift, 9, movetoworkspace, 9"
          "SUPER+Shift, 0, movetoworkspace, 10"
          "SUPER+Shift, mouse_down, movetoworkspace, -1"
          "SUPER+Shift, mouse_up, movetoworkspace, +1"
          "SUPER+Shift, S, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, up, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, down, movetoworkspace, e+0"

          # Apps and launcher
          "SUPER, E, exec, $terminal"
          "SUPER, W, exec, $browser"
          "SUPER, T, exec, $file-manager"
          "SUPER, Z, exec, pkill fuzzel || fuzzel"

          # Screenshot & colour picker
          "Ctrl+Alt, C, exec, hyprpicker -a"
        ];

        binde = [
          # Resize split
          "SUPER, Minus, splitratio, -0.1"
          "SUPER, Equal, splitratio, 0.1"
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
          "SUPER+Shift, Escape, exec, systemctl suspend-then-hibernate"
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
          # libinput edge scrolling for touchpads (vertical scrolling on edge zone).
          # Note: libinput uses the right edge for vertical edge scroll.
          scroll_method = "edge";
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 1.0;
          };
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
      LIBVA_DRIVER_NAME = "iHD";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1"; # Fixes invisible cursor on NVIDIA
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
