{
  pkgs,
  lib,
  packageConfig,
  programSystemd ? {
    enable = false;
    target = "graphical-session.target";
    environment = [];
  },
  settingsOverrides ? {},
  enabled,
  ...
}: let
  caelestiaKeybinds = import ./keys.nix;
  caelestiaSettings = import ./settings.nix;
  inherit (packageConfig) homePackages package;
in {
  home = {config, ...}:
    lib.mkIf enabled {
      home.packages = homePackages;

      programs.caelestia = {
        enable = true;
        inherit package;
        systemd = programSystemd;
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
    security.wrappers.gsr-kms-server = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    };

    services.upower.enable = true;
  };
}
