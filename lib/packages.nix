{
  lib,
  inputs,
  user,
  home-lib,
  pkgs,
}:
let
  progDir = ../programs;
  currentSystem = pkgs.stdenv.hostPlatform.system;
in
pkgName:
let
  hmModule = inputs.${pkgName}.homeManagerModules.default or null;
  hasExternalHMModule = hmModule != null;

  progModule = import (progDir + "/${pkgName}/default.nix") {
    inherit lib pkgs inputs;
    enabled = true;
  };

  moduleToUse = 
    if hasExternalHMModule then
      progModule.config or progModule
    else
      progModule;

  hmResult = builtins.tryEval (
    home-lib.homeManagerConfiguration {
      inherit pkgs;
      modules = (
        lib.optional hasExternalHMModule hmModule
        ++ [
          moduleToUse
          {
            home = {
              username = user;
              homeDirectory = "/home/${user}";
              stateVersion = "24.11";
            };
          }
        ]
      );
    }
  );

  hmConfig = if hmResult.success then hmResult.value else null;

  progConfig = if hmConfig != null then hmConfig.config.programs.${pkgName} or {} else {};

  finalPkg =
    if progConfig ? finalPackage then
      progConfig.finalPackage
    else if progConfig ? package then
      progConfig.package
    else if inputs.${pkgName} ? packages then
      inputs.${pkgName}.packages.${currentSystem}.default
    else if hmResult.success then
      throw "Package '${pkgName}' has no finalPackage or package attribute in HM config"
    else
      throw "Failed to build HM config and no flake package available for '${pkgName}'";

  warnMsg =
    if hmConfig == null && hasExternalHMModule then
      "Warning: ${pkgName} failed to build HM config - using flake package"
    else if !hasExternalHMModule then
      "Warning: ${pkgName} has no homeManagerModules in inputs - using flake package"
    else if ! (progConfig ? finalPackage) then
      "Warning: ${pkgName} has no finalPackage - using package attribute"
    else null;
in
lib.warnIf (warnMsg != null) warnMsg finalPkg
