{
  lib,
  enabled,
  ...
}: {
  home = lib.mkIf enabled {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
        silent = true;
      };
      bash.enable = true;
      zsh.enable = true;
    };
  };
  nixos = lib.mkIf enabled {};
}
