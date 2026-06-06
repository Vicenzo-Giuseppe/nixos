{ inputs, ... }:
let
  root = inputs.self;
  ctx = import (inputs.self + /lib/context.nix);
  system = ctx.system;
  user = ctx.user;
  host = ctx.host;
  enabledPrograms = [
    "aria2"
    "bat"
    "code"
    "copyparty"
    "hyprland"
    "xdg"
    "direnv"
    "firefox"
    "home"
    "pkgs"
    "starship"
    "zen-browser"
    "zsh"
    "mnw"
    "sops"
    "openssh"
    "btop"
    "spicetify"
    "screenpipe"
    "steam"
    "amnezia-vpn"
    "localsend"
    "caelestia"
    "soft-serve"
    "spacedrive"
    #"spacebot"
  ];
in
{
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  _module.args = {
    inherit
      inputs
      system
      user
      host
      enabledPrograms
      ;
  };

  imports = [
    inputs.disko.nixosModules.disko
    ../nix-settings.nix
    ../vicenzo.nix
    ../boot.nix
    ../audio.nix
    ./attic.nix
    ./build-telemetry.nix
    ./hardware.nix
    ./filesystem.nix
    ./loq-15IRH8.nix
    (import (root + /lib/nixos.nix) {
      inherit inputs user host;
      programs = enabledPrograms;
    })
    (import (root + /home/default.nix) {
      inherit
        host
        user
        inputs
        system
        enabledPrograms
        ;
    })
  ];
}
