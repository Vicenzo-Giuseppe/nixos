# lib/packages.nix - Build packages from programs using homeManagerConfiguration
{
  lib,
  inputs,
  user,
  home-lib,
  pkgs,
}: pkg: let
  progDir = ../programs;
  Module = import (progDir + "/${pkg}/default.nix") {
    inherit lib pkgs;
    enabled = true;
  };
  Packages = home-lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      inputs.${pkg}.homeManagerModules.default
      Module.config
      {
        home = {
          username = user;
          homeDirectory = "/home/${user}";
          stateVersion = "24.11";
        };
      }
    ];
  };
in {
  inherit Packages;
}
