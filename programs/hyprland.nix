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
        "$editor" = "zv";
        "$volumeStep" = "10";

        # ── Caelestia Launcher ──
        bindi = [ "SUPER, SUPER_L, global, caelestia:launcher" ];


        bind = [
          # Caelestia globals
          "Ctrl+Alt, Delete, global, caelestia:session"
          "SUPER, K, global, caelestia:showall"
          "SUPER, L, global, caelestia:lock"

          # Window focus
          "SUPER, left, movefocus, l"
          "SUPER, right, movefocus, r"
          "SUPER, up, movefocus, u"
          "SUPER, down, movefocus, d"

          # Move windows
          "SUPER+Shift, left, movewindow, l"
          "SUPER+Shift, right, movewindow, r"
          "SUPER+Shift, up, movewindow, u"
          "SUPER+Shift, down, movewindow, d"

          # Window actions
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 0"
          "SUPER+Alt, F, fullscreen, 1"
          "SUPER+Alt, Space, togglefloating,"
          "SUPER, P, pin"
          "Ctrl+SUPER, Backslash, centerwindow, 1"

          # Window groups
          "SUPER, Comma, togglegroup"
          "SUPER, U, moveoutofgroup"
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
          "SUPER+Alt, 1, movetoworkspace, 1"
          "SUPER+Alt, 2, movetoworkspace, 2"
          "SUPER+Alt, 3, movetoworkspace, 3"
          "SUPER+Alt, 4, movetoworkspace, 4"
          "SUPER+Alt, 5, movetoworkspace, 5"
          "SUPER+Alt, 6, movetoworkspace, 6"
          "SUPER+Alt, 7, movetoworkspace, 7"
          "SUPER+Alt, 8, movetoworkspace, 8"
          "SUPER+Alt, 9, movetoworkspace, 9"
          "SUPER+Alt, 0, movetoworkspace, 10"
          "SUPER+Alt, mouse_down, movetoworkspace, -1"
          "SUPER+Alt, mouse_up, movetoworkspace, +1"
          "SUPER+Alt, S, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, up, movetoworkspace, special:special"
          "Ctrl+SUPER+Shift, down, movetoworkspace, e+0"

          # Special workspace toggles
          "SUPER, S, exec, caelestia toggle specialws"
          "Ctrl+Shift, Escape, exec, caelestia toggle sysmon"
          "SUPER, M, exec, caelestia toggle music"
          "SUPER, D, exec, caelestia toggle communication"
          "SUPER, R, exec, caelestia toggle todo"

          # Apps
          "SUPER, T, exec, $terminal"
          "SUPER, W, exec, $editor"
          "Ctrl+Alt, V, exec, pavucontrol"

          # Screenshot & colour picker
          "SUPER+Shift, S, global, caelestia:screenshotFreeze"
          "SUPER+Shift+Alt, S, global, caelestia:screenshot"
          "SUPER+Shift, C, exec, hyprpicker -a"

          # Clipboard & emoji
          "SUPER, V, exec, pkill fuzzel || caelestia clipboard"
          "SUPER+Alt, V, exec, pkill fuzzel || caelestia clipboard -d"
          "SUPER, Period, exec, pkill fuzzel || caelestia emoji -p"
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
          # Caelestia globals
          "Ctrl+Alt, C, global, caelestia:clearNotifs"
          "SUPER+Alt, L, global, caelestia:lock"
          "SUPER+Alt, L, exec, caelestia shell -d"
          # Brightness
          ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
          ", XF86MonBrightnessDown, global, caelestia:brightnessDown"
          # Media
          "Ctrl+SUPER, Space, global, caelestia:mediaToggle"
          ", XF86AudioPlay, global, caelestia:mediaToggle"
          ", XF86AudioPause, global, caelestia:mediaToggle"
          ", XF86AudioStop, global, caelestia:mediaStop"
          "Ctrl+SUPER, Equal, global, caelestia:mediaNext"
          ", XF86AudioNext, global, caelestia:mediaNext"
          "Ctrl+SUPER, Minus, global, caelestia:mediaPrev"
          ", XF86AudioPrev, global, caelestia:mediaPrev"
          # Volume
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "SUPER+Shift, M, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          # Screenshot
          ", Print, exec, caelestia screenshot"
          # Screen record
          "SUPER+Alt, R, exec, caelestia record -s"
          "Ctrl+Alt, R, exec, caelestia record"
          "SUPER+Shift+Alt, R, exec, caelestia record -r"
          # Sleep
          "SUPER+Shift, L, exec, systemctl suspend-then-hibernate"
        ];

        bindle = [
          ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $volumeStep%+"
          ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ $volumeStep%-"
        ];

        bindr = [
          "Ctrl+SUPER+Shift, R, exec, qs -c caelestia kill"
          "Ctrl+SUPER+Alt, R, exec, qs -c caelestia kill; sleep .1; caelestia shell -d"
        ];

        exec-once = [
          "caelestia shell -d"
        ];

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
      inputs.caelestia.packages.${pkgs.system}.with-cli
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

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_QPA_PLATFORM = "wayland;xcb";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
