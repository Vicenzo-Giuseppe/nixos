{
  #wsl,
  home,
  host,
  user,
  inputs,
  system,
  Config,
}:
let
  colors = import ./colors.nix;
  inherit (inputs)
    mnw
    spicetify
    cosmic-manager
    sops
    caelestia
    #caelestia-dots
    zen-browser
    ;
in
[
  home.nixosModules.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user} =
        { ... }:
        {
          imports = [
            zen-browser.homeModules.twilight
            cosmic-manager.homeManagerModules.default
            caelestia.homeManagerModules.default
            mnw.homeManagerModules.default
            sops.homeManagerModules.default
            #caelestia-dots.homeManagerModules.default
            ../lib/home.nix
          ];
        };
      extraSpecialArgs = {
        inherit
          host
          user
          inputs
          system
          colors
          Config
          ;
      };
    };
  }
  spicetify.nixosModules.spicetify
  sops.nixosModules.sops
  # microvm.nixosModules.host import ./microvm.nix
]
