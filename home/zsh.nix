{config, ...}: let
  inherit (config.home) homeDirectory;
  zshNixDir = ".config/.zshrc.nix";
  histDir = "${homeDirectory}/.config/zsh/.zhistory";
  username = "Vicenzo Giuseppe Furno Baptista";
  zshrc = ''
    #!/usr/bin/env bash
    export ZDOTDIR=$HOME/.config/zsh/
    source "$ZDOTDIR/init.sh"
    source "$ZDOTDIR/functions.sh"
    add_file "exports"
  '';
in {
  programs.zsh = {
    enable = true;
    dotDir = zshNixDir;
    history = {
      path = histDir;
      extended = false;
    };
    initExtra = zshrc;
    sessionVariables = {
      inherit username;
    };
    shellAliases = {};
  };
}
