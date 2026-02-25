## lib/programs.nix - Registro de Programas (Sem Categorias)
{lib}: let
  programsDir = ../programs;

  # Lê o diretório e filtra apenas o que é diretório (seu workflow original)
  # Se você usa arquivos .nix direto, mude para: (n: dir.${n} == "directory" || lib.hasSuffix ".nix" n)
  dir = builtins.readDir programsDir;

  # Aqui pegamos todos os itens que são diretórios ou arquivos .nix
  allProgramsRaw = builtins.filter (
    n:
      dir.${n} == "directory" || (dir.${n} == "regular" && lib.hasSuffix ".nix" n)
  ) (builtins.attrNames dir);

  # Limpa o nome (remove .nix se for arquivo)
  cleanName = n: lib.removeSuffix ".nix" n;

  # Mantendo a semântica original de categorias, mas "fingindo" que
  # a única categoria existente se chama "default" ou "programs"
  programDb = {
    all = map cleanName allProgramsRaw;
  };

  # Mantendo as variáveis que seu código espera:
  all = programDb.all;

  categories = ["all"]; # Agora só existe uma categoria virtual

  # Mapeia cada programa para a categoria virtual "all"
  toCat = builtins.listToAttrs (map (p: {
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

  # Ajustado para procurar direto na raiz de programsDir
  path = program: type: let
    # Verifica se existe a pasta com default.nix ou o arquivo .nix direto
    isDir = builtins.pathExists (programsDir + "/${program}/default.nix");
  in
    if isDir
    then programsDir + "/${program}/default.nix"
    else programsDir + "/${program}.nix";
}
