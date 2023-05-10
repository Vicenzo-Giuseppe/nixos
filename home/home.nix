{pkgs, ...}: {
  home = {
    username = "vicenzo";
    homeDirectory = "/home/vicenzo";
    stateVersion = "22.11";
    sessionVariables = {};
  };
  programs.neovim.enable = true;
}
