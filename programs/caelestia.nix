{
  pkgs,
  lib,
  enabled,
  ...
}:
let
in
{
  home = lib.mkIf enabled {
    programs.caelestia = {
      enable = true;
      systemd = {
        enable = false; # if you prefer starting from your compositor
        target = "graphical-session.target";
        environment = [ ];
      };
      settings = {
        bar.status = {
          showBattery = true;
        };
        paths.wallpaperDir = "~/Images";
      };
      cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
          theme.enableGtk = false;
        };
      };
    };

  };
  nixos = lib.mkIf enabled {
  };
}
