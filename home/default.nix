{
  host,
  user,
  inputs,
  system,
  enabledPrograms,
  ...
}: let
  colors = import ./colors.nix;
  inherit (inputs) home spicetify sops spacebot;
in {
  imports = [
    home.nixosModules.home-manager
    spicetify.nixosModules.spicetify
    spacebot.nixosModules.default
    sops.nixosModules.sops
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user}.imports = [
      (import ./profile.nix {
        inherit inputs user host system enabledPrograms;
      })
    ];
    extraSpecialArgs = {
      inherit host user inputs system colors enabledPrograms;
    };
  };
}
