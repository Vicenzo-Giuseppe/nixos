{
  user,
  pkgs,
  inputs,
  lib,
  enabled,
  ...
}: let
  source = pkgs.fetchgit {
    url = "https://codeberg.org/Vicenzo/wezterm";
    sha256 = "sha256-LWqLoEf7aBF1addnhBpecAn0mdvTLY415GIWIFBCYYM=";
  };
  source2 = pkgs.fetchgit {
    url = "https://codeberg.org/Vicenzo/xplr";
    sha256 = "sha256-/gf3bFgWMq8dxT2L5I2w27kqHOO9TT/SU2BNPyI+umY=";
  };
in {
  home = lib.mkIf enabled {
    home = {
      username = user;
      homeDirectory = lib.mkForce "/home/${user}";
      stateVersion = "24.11";
      file.wezterm = {
        inherit source;
        target = ".config/wezterm";
      };
      file.xplr = {
        source = source2;
        target = ".config/xplr";
      };
      file.".config/stormy/stormy.toml".source = "${pkgs.stormy}/etc/stormy/stormy.toml";
      packages = with pkgs; [
        xplr
        stormy
      ];
    };
  };
  nixos = lib.mkIf enabled {};
}
