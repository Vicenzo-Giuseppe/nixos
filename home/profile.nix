{
  inputs,
  user,
  host,
  system,
  enabledPrograms,
  ...
}: {
  imports = [
    inputs.zen-browser.homeModules.twilight
    inputs.cosmic-manager.homeManagerModules.default
    inputs.mnw.homeManagerModules.default
    inputs.sops.homeManagerModules.default
    inputs.caelestia-src.homeManagerModules.default
    (import ../lib/home.nix {
      inherit inputs user host;
      programs = enabledPrograms;
    })
  ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";
}
