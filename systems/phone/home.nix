{context, inputs}: {
  lib,
  ...
}: let
  user = context.user;
  host = context.host;
  colors = import ../../home/colors.nix;
in {
  imports = [
    inputs.mnw.homeManagerModules.default
    (import ../../lib/home.nix {
      inherit inputs user host;
      programs = [
        "bat"
        "copyparty"
        "direnv"
        "mnw"
        "openssh"
        "starship"
        "zsh"
      ];
    })
  ];

  _module.args = {inherit colors;};

  home.username = lib.mkForce user;
  home.homeDirectory = lib.mkForce "/data/data/com.termux.nix/files/home";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
