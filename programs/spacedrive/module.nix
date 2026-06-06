{
  lib,
  enabled,
  packageConfig,
  ...
}: let
  inherit (packageConfig) package homePackages;
in {
  home = lib.mkIf enabled {
    home.packages = [
      package
    ] ++ homePackages;
  };

  nixos = lib.mkIf enabled {
    services.gnome.gnome-keyring.enable = true;
  };
}
