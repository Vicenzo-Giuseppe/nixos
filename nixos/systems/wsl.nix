{
  pkgs,
  user,
  ...
}: let
  imports = [
    ./cachix.nix
    ./user-config.nix
  ];
in {
  inherit imports;
  wsl = {
    enable = true;
    nativeSystemd = true;
    wslConf.automount.root = "/mnt";
    defaultUser = user;
    startMenuLaunchers = true;
    #docker-native.enable = true;
    #docker-desktop.enable = true;
  };
}
