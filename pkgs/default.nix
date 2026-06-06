{
  pkgs,
  inputs ? {},
  ...
}:
with builtins; let
  files = readDir ./.;
  nixFiles = filter (
    name:
      match ".*\\.nix" name
      != null
      && name != "default.nix"
      && name != "config.nix"
      && name != "set.nix"
      && name != "packages.nix"
      && name != "run.nix"
  ) (attrNames files);

  mkPackage = name: let
    file = ./. + "/${name}";
    packageFn = import file;
    wantsInputs = isFunction packageFn && hasAttr "inputs" (functionArgs packageFn);
    extraArgs =
      if wantsInputs
      then {inherit inputs;}
      else {};
  in {
    name = replaceStrings [".nix"] [""] name;
    value = pkgs.callPackage file extraArgs;
  };
in
  listToAttrs (map mkPackage nixFiles)
