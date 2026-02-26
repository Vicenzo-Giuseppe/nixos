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
  hmModule = 
    if inputs ? ${pkgName} then 
      inputs.${pkgName}.homeManagerModules.default or null 
    else 
      null;
  hasExternalHMModule = hmModule != null;

  # Get sops module from flake inputs (if available)
  sopsModule = 
    if inputs ? sops then 
      inputs.sops.homeManagerModules.sops or null 
    else 
      null;
  hasSopsModule = sopsModule != null;

  # Check if envs.yaml exists (unencrypted envs)
  envsFile = progDir + "/sops/envs.yaml";
  hasEnvsFile = builtins.pathExists envsFile;

  # Try importing program module
  progModuleResult = builtins.tryEval (
    import (progDir + "/${pkgName}/default.nix") {
      inherit lib pkgs inputs;
      enabled = true;
    }
  );

  progModule = 
    if progModuleResult.success then
      progModuleResult.value
    else
      import (progDir + "/${pkgName}/default.nix") {
        inherit lib pkgs;
        enabled = true;
      };

  # Handle different module formats
  moduleToUse = 
    if progModule ? config then
      progModule.config
    else if progModule ? home then
      progModule.home
    else
      progModule;

  # Build sops config - use envs.yaml if exists, otherwise empty
  sopsConfig = 
    if hasEnvsFile then
      {
        sops = {
          defaultSopsFile = envsFile;
          defaultSopsFormat = "yaml";
          secrets = {};
        };
      }
    else if hasSopsModule then
      {
        sops = {
          defaultSopsFile = progDir + "/sops/secrets.yaml";
          defaultSopsFormat = "yaml";
          age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
          secrets = {};
        };
      }
    else
      {};

  # Build HM configuration - include external module and sops if available
  modulesList = 
    if hasExternalHMModule then
      [hmModule]
    else
      []
    ++ lib.optional hasSopsModule sopsModule
    ++ lib.optional (sopsConfig != {}) sopsConfig
    ++ [moduleToUse];

  hmResult = builtins.tryEval (
    home-lib.homeManagerConfiguration {
      inherit pkgs;
      modules = modulesList ++ [
        {
          home = {
            username = user;
            homeDirectory = "/home/${user}";
            stateVersion = "24.11";
          };
        }
      ];
    }
  );

  hmConfig = if hmResult.success then hmResult.value else null;

  progConfig = if hmConfig != null then hmConfig.config.programs.${pkgName} or {} else {};

  # Check if flake input has packages for current system
  hasFlakeInput = 
    inputs ? ${pkgName} 
    && inputs.${pkgName} ? packages
    && inputs.${pkgName}.packages ? ${currentSystem}
    && inputs.${pkgName}.packages.${currentSystem} ? default;
    
  flakePkg = if hasFlakeInput then inputs.${pkgName}.packages.${currentSystem}.default else null;

  # Priority: finalPackage > package > flake input > nixpkgs
  finalPkg =
    if progConfig ? finalPackage then
      progConfig.finalPackage
    else if progConfig ? package then
      progConfig.package
    else if hasFlakeInput then
      flakePkg
    else if hmResult.success then
      pkgs.${pkgName} or (throw "Package '${pkgName}' not in nixpkgs")
    else
      pkgs.${pkgName} or (throw "Package '${pkgName}' not found");

  warnMsg =
    if hmConfig == null then
      "Warning: ${pkgName} HM config failed - using fallback"
    else if !hasEnvsFile && hasSopsModule then
      "Warning: ${pkgName} envs.yaml not found - add programs/sops/envs.yaml for secrets"
    else if hasEnvsFile then
      "Warning: ${pkgName} using envs.yaml (unencrypted)"
    else if !hasSopsModule then
      "Warning: ${pkgName} no sops module - secrets not available"
    else if !hasExternalHMModule then
      "Warning: ${pkgName} has no homeManagerModules - using local config"
    else null;
in
lib.warnIf (warnMsg != null) warnMsg finalPkg
