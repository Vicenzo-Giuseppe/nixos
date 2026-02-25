{pkgs, ...}:
with builtins; let
  files = readDir ./.;
  nixFiles = filter (name: match ".*\\.nix" name != null && name != "default.nix") (attrNames files);
in
  listToAttrs (
    map (name: {
      name = replaceStrings [".nix"] [""] name;
      value = pkgs.callPackage (./. + "/${name}") {};
    })
    nixFiles
  )
