{config, ...}: let
  features = ["nix-command" "flakes"];
  user = "vicenzo";
in {
  nix.settings = {
    experimental-features = features;
    trusted-users = [user "root"];
    substituters = [https://cache.nixos.org https://cache.nixos.org/ https://zv.cachix.org https://devenv.cachix.org];
    trusted-public-keys = [cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= zv.cachix.org-1:IvFyOKHzPNNVSapGzeNPbrF65OoX/r+MROLHpGwsYfg=];
  };
}
