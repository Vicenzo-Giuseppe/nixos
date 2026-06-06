{
  inputs,
  cell ? {},
  baseDir,
  rootConfig ? import (inputs.self + /lib/context.nix),
}: let
  pkgs = import inputs.nixpkgs {
    system = rootConfig.system;
    config = import (inputs.self + /home/nix-config.nix) {
      inherit (inputs) nixpkgs;
    };
    overlays = import (inputs.self + /home/overlays.nix) {inherit inputs;};
  };

  inherit (pkgs) lib;
  inherit (rootConfig) system user host;

  colors = import (inputs.self + /home/colors.nix);
  dir = builtins.readDir baseDir;

  callWith = value: args:
    if builtins.isFunction value
    then value (builtins.intersectAttrs (builtins.functionArgs value) args)
    else value;

  importWith = path: args: callWith (builtins.scopedImport args path) args;

  cleanName = name: lib.removeSuffix ".nix" name;

  hasModule = name:
    dir.${name} == "directory"
    && (
      builtins.pathExists (baseDir + "/${name}/module.nix")
      || builtins.pathExists (baseDir + "/${name}/default.nix")
    );

  moduleNames = let
    folderNames = builtins.filter hasModule (builtins.attrNames dir);
    fileNames = builtins.filter (
      name:
        dir.${name}
        == "regular"
        && lib.hasSuffix ".nix" name
        && !builtins.elem name [
          "package.nix"
          "config.nix"
          "default.nix"
          "module.nix"
          "packages.nix"
          "run.nix"
          "shell.nix"
          "set.nix"
        ]
        && !(builtins.elem (cleanName name) folderNames)
    ) (builtins.attrNames dir);
  in
    lib.sort lib.lessThan (folderNames ++ builtins.map cleanName fileNames);

  leafNamesWith = fileName:
    lib.sort lib.lessThan (builtins.filter (
      name:
        dir.${name} == "directory" && builtins.pathExists (baseDir + "/${name}/${fileName}")
    ) (builtins.attrNames dir));

  hasDir = name:
    builtins.hasAttr name dir && dir.${name} == "directory";

  modulePath = name:
    if hasDir name && builtins.pathExists (baseDir + "/${name}/module.nix")
    then baseDir + "/${name}/module.nix"
    else if hasDir name && hasModule name
    then baseDir + "/${name}/default.nix"
    else baseDir + "/${name}.nix";

  commonArgs = inputs // {
    inherit inputs cell pkgs lib colors system user host rootConfig;
    context = rootConfig;
    enabled = true;
  };

  packageNames = leafNamesWith "package.nix";

  evalPackage = name:
    let
      raw = importWith (baseDir + "/${name}/package.nix") (
        commonArgs
        // {
          folderName = name;
          moduleName = name;
          inherit name;
        }
      );
      value =
        if builtins.isAttrs raw && builtins.hasAttr "output" raw then
          raw.output
        else if builtins.isAttrs raw && builtins.hasAttr "default" raw then
          raw.default
        else
          raw;
    in
      if builtins.isAttrs value then value else { package = value; };

  packageOutputs = builtins.listToAttrs (builtins.map (
    name: {
      inherit name;
      value = evalPackage name;
    }
  ) packageNames);

  configNames = leafNamesWith "config.nix";

  evalConfig = name:
    let
      raw = importWith (baseDir + "/${name}/config.nix") (argsFor name {
        packageConfig = packageOutputs.${name} or {};
        config = {};
        output = {};
      });
      value =
        if builtins.isAttrs raw && builtins.hasAttr "output" raw then
          callWith raw.output (argsFor name {
            packageConfig = packageOutputs.${name} or {};
            config = {};
            output = {};
          })
        else if builtins.isAttrs raw && builtins.hasAttr "default" raw then
          callWith raw.default (argsFor name {
            packageConfig = packageOutputs.${name} or {};
            config = {};
            output = {};
          })
        else
          raw;
    in
      if builtins.isAttrs value then value else {output = value;};

  configOutputs = builtins.listToAttrs (builtins.map (
    name: {
      inherit name;
      value = evalConfig name;
    }
  ) configNames);

  modules = builtins.listToAttrs (builtins.map (
      name: {
        inherit name;
        value = importWith (modulePath name) (argsFor name {});
      }
    )
    moduleNames);

  argsFor = name: extra:
    let
      packageConfig = packageOutputs.${name} or {};
      output =
        if builtins.hasAttr "output" extra then
          extra.output
        else if builtins.hasAttr "config" extra then
          extra.config
        else
          configOutputs.${name} or {};
    in
    commonArgs
    // {
      inherit modules;
      folderName = name;
      moduleName = name;
      name = output.name or name;
      inherit packageConfig;
      inherit output;
      config = output;
      module =
        modules.${
          name
        } or {
          home = {};
          nixos = {};
        };
    }
    // output
    // extra;

  config = builtins.listToAttrs (builtins.map (
    name: {
      inherit name;
      value = configOutputs.${name};
    }
  ) configNames);

  runnables = builtins.listToAttrs (builtins.map (
    name: {
      inherit name;
      value = importWith (baseDir + "/${name}/run.nix") (argsFor name {
        config = cell.config.${name} or config.${name} or {};
        output = cell.config.${name} or config.${name} or {};
      });
    }
  ) (leafNamesWith "run.nix"));

  shells = builtins.listToAttrs (builtins.map (
    name: {
      inherit name;
      value = importWith (baseDir + "/${name}/shell.nix") (argsFor name {
        config = cell.config.${name} or config.${name} or {};
        output = cell.config.${name} or config.${name} or {};
        mkShell = inputs.std.${system}.lib.dev.mkShell;
      });
    }
  ) (leafNamesWith "shell.nix"));
in {
  inherit
    pkgs
    lib
    colors
    system
    user
    host
    rootConfig
    modules
    config
    runnables
    shells
    moduleNames
    leafNamesWith
    importWith
    argsFor
    ;
}
