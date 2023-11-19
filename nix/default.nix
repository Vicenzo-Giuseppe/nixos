{
  nixpkgs,
  user,
  ...
}: let
  experimental-features = ["nix-command" "flakes"];
  trusted-users = [user "root"];
in {
  permittedInsecurePackages = [
    "python-2.7.18.6"
    "qtwebkit-5.212.0-alpha4"
    "electron-12.2.3"
  ];
  allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) [
      "google-chrome"
      "steam-original"
      "steam-run"
      "steamcmd"
      "lunar-client"
      "discord"
      "steam"
      "flagfox"
    ];
  nix.settings = {
    inherit trusted-users experimental-features;
    substitures = [https://cache.nixos.org/ https://zv.cachix.org];
    trusted-public-keys = [cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= zv.cachix.org-1:IvFyOKHzPNNVSapGzeNPbrF65OoX/r+MROLHpGwsYfg=];
  };
}
