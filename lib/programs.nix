## lib/programs.nix - Registro de Programas (Sem Categorias)
{lib}: let
  programsDir = ../programs;
  dir = builtins.readDir programsDir;

  folderPrograms = builtins.filter (
    n:
      dir.${n} == "directory"
      && (
        builtins.pathExists (programsDir + "/${n}/module.nix")
        || builtins.pathExists (programsDir + "/${n}/default.nix")
      )
  ) (builtins.attrNames dir);

  filePrograms = builtins.filter (
    n:
      dir.${n}
      == "regular"
      && lib.hasSuffix ".nix" n
      && !(builtins.elem (cleanName n) folderPrograms)
      && !(builtins.elem n [
        "config.nix"
        "module.nix"
        "default.nix"
        "run.nix"
        "shell.nix"
      ])
  ) (builtins.attrNames dir);

  cleanName = n: lib.removeSuffix ".nix" n;

  programDb = {
    all = lib.sort lib.lessThan (folderPrograms ++ builtins.map cleanName filePrograms);
  };

  inherit (programDb) all;

  categories = ["all"];

  toCat = builtins.listToAttrs (builtins.map (p: {
      name = p;
      value = "all";
    })
    all);
in {
  inherit
    programDb
    categories
    all
    toCat
    ;

  path = program: _type: let
    modulePath = programsDir + "/${program}/module.nix";
    defaultPath = programsDir + "/${program}/default.nix";
    filePath = programsDir + "/${program}.nix";
  in
    if builtins.pathExists modulePath
    then modulePath
    else if builtins.pathExists defaultPath
    then defaultPath
    else filePath;
}
