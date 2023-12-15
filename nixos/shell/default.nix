{
  pkgs,
  inputs,
  devenv,
  ...
}: {
  default = devenv.lib.mkShell {
    inherit pkgs inputs;
    modules = [
      {
        packages = with pkgs; [
          #starship
          #exa
          #neovim
          #git
          #direnv
          #zsh
        ];
        enterShell = builtins.readFile ./shell.sh;
      }
    ];
  };
}
#{
#  default = pkgs.mkShell {
#              inputsFrom = [ inputs.holochain.devShells.x86_64-linux.holonix ];
#              packages = zshShellPkgs;
#              shellHook =  builtins.readFile ./shell.sh;
#            };
#}

