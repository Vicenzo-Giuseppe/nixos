{pkgs, ...}: let
  plugins = import ./plugins.nix;
  aliases = import ./aliases.nix;
in {
  imports = [plugins aliases];
  home = {
    packages = with pkgs; [eza neovim];
  };
  programs.zsh = {
    enable = true;
    autocd = true;
    cdpath = map toString [/etc/nixos];
    #defaultKeymap = "vicmd";
    dirHashes = {
      down = "$HOME/Downloads";
    };
  };
}
