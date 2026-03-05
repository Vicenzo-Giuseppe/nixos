{
  pkgs,
  lib,
  enabled,
  ...
}: let
in {
  home =
    lib.mkIf enabled {
    programs.caelestia-dots = {
    enable = true;
    hypr.hyprland.keybinds.settings.bind = ["Ctrl+Alt, a, exec, footclient"]; # Appends new bind
    caelestia.shell.settings = {
      launcher.actionPrefix = "."; # Set a value
      battery.warnLevels.__prepend = [ # Prepending to the defaults, without rewriting them all
          {
            level = 80;
            title = "High Battery";
            message = "Consider unpluging the charger for the battery safety";
            icon = "battery_android_frame_5";
          }
        ]; # Warn when 80% of battery
    };
  };    };
  nixos = lib.mkIf enabled {
  };
}
