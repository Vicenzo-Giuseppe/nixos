{
  pkgs,
  lib,
  enabled,
  ...
}: let
  caelestiaSettings = import ./caelestia/settings.nix;
  caelestiaKeybinds = import ./caelestia/keys.nix;
  settingsOverrides = {}; # quick UI tweaks live here if you don't want to touch the defaults
in {
  home = {config, ...}:
    lib.mkIf enabled {
      home.packages = with pkgs; [gpu-screen-recorder];

      programs.caelestia = {
        enable = true;
        systemd = {
          enable = false;
          target = "graphical-session.target";
          environment = [];
        };
        cli = {
          enable = true;
          settings = {
            theme.enableGtk = true;
          };
        };
        settings = lib.recursiveUpdate caelestiaSettings settingsOverrides;
      };

      wayland.windowManager.hyprland.settings = {
        bindi = lib.mkAfter caelestiaKeybinds.bindi;
        bind = lib.mkAfter caelestiaKeybinds.bind;
        bindl = lib.mkAfter caelestiaKeybinds.bindl;
        bindr = lib.mkAfter caelestiaKeybinds.bindr;
        "exec-once" = lib.mkAfter caelestiaKeybinds."exec-once";
      };
    };

  nixos = lib.mkIf enabled {
    # gpu-screen-recorder without auth
    security.wrappers.gsr-kms-server = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    };

    # battery view
    services.upower.enable = true;
  };
}
