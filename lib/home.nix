# modules/home.nix - Home Manager entry via NixOS
{
  pkgs,
  lib,
  inputs,
  Config,
  ...
}: let
  inherit (Config) host user;
  cfg = import ./config.nix {inherit lib;};
  prog = import ./programs.nix {inherit lib;};
  cfgFile = cfg.load ../config.toml;
  colors = import ../systems/colors.nix;
  enabledHome = builtins.filter (p: builtins.pathExists (prog.path p "home")) (cfg.enabled cfgFile);

  programConfigs =
    builtins.map (
      p: let
        path = prog.path p "home";
        isEnabled = cfg.isEnabled cfgFile p;
      in
        (import path {
          inherit
            lib
            pkgs
            inputs
            user
            host
            colors
            ;
          enabled = isEnabled;
        }).home
    )
    enabledHome;
in {
  imports = programConfigs;
}
