{
  lib,
  enabled,
  packageConfig,
  ...
}: let
  inherit (packageConfig) package homePackages isPhone openScript;
in {
  home = lib.mkIf enabled {
    home.packages = [package] ++ homePackages;

    home.file = lib.mkIf isPhone {
      ".termux/termux.properties".text = ''
        allow-external-apps = true
      '';
    };

    xdg.desktopEntries = lib.mkIf (!isPhone) {
      copyparty-phone = {
        name = "Phone Videos";
        genericName = "Open phone video library";
        exec = "${openScript}/bin/copyparty-phone-open";
        terminal = false;
        categories = [
          "Network"
          "AudioVideo"
        ];
      };
    };
  };

  nixos = lib.mkIf enabled {};
}
