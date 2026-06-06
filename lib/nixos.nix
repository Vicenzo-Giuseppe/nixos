# modules/nixos.nix - NixOS entry via explicit program list
{
  inputs,
  user,
  host,
  programs,
}: {
  pkgs,
  lib,
  ...
}: let
  root = inputs.self;
  rootConfig = import (root + /lib/context.nix);
  prog = import ./programs.nix {inherit lib;};
  system = pkgs.stdenv.hostPlatform.system;
  baseArgs = {
    inherit lib pkgs inputs user host system rootConfig;
    context = rootConfig;
    enabled = true;
  };
  callWith = value: args:
    if builtins.isFunction value
    then value (builtins.intersectAttrs (builtins.functionArgs value) args)
    else value;
  packageOutput = p: let
    packagePath = root + "/programs/${p}/package.nix";
    raw =
      if builtins.pathExists packagePath
      then callWith (builtins.scopedImport baseArgs packagePath) baseArgs
      else {};
    value = raw.output or raw;
  in
    if builtins.isAttrs value then value else {package = value;};
  configOutput = p: let
    configPath = root + "/programs/${p}/config.nix";
    packageConfig = packageOutput p;
    raw =
      if builtins.pathExists configPath
      then callWith (builtins.scopedImport (baseArgs // {inherit packageConfig;}) configPath) (baseArgs // {inherit packageConfig;})
      else {};
    value = raw.output or raw;
  in
    if builtins.isAttrs value then value else {output = value;};
  enabledNixos = builtins.filter (p: builtins.pathExists (prog.path p "nixos")) programs;
  programImport = p: let
    packageConfig = packageOutput p;
    output = configOutput p;
    args = baseArgs // {
      inherit packageConfig;
    } // output // {
      inherit output;
      config = output;
    };
  in
    (callWith (builtins.scopedImport args (prog.path p "nixos")) args)
    .nixos;
in {
  imports = builtins.map programImport enabledNixos;
}
