# modules/nixos.nix - NixOS entry
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = import ./config.nix {inherit lib;};
  prog = import ./programs.nix {inherit lib;};
  cfgFile = cfg.load ../config.toml;
  user = cfg.user cfgFile;
  host = cfg.host cfgFile;
  enabledNixos = builtins.filter (p: builtins.pathExists (prog.path p "nixos")) (cfg.enabled cfgFile);
  programImport = p: let
    path = prog.path p "nixos";
    isEnabled = cfg.isEnabled cfgFile p;
  in
    (import path {
      inherit
        lib
        pkgs
        inputs
        user
        host
        ;
      enabled = isEnabled;
    }).nixos;
in {
  imports = builtins.map programImport enabledNixos;
}
