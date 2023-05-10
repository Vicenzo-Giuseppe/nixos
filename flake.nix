{
  outputs = inputs @ {
    self,
    home,
    nixpkgs,
    utils,
    neovim,
    nur,
    devenv,
    ...
  }: let
    system = import ./system;
    modules = [
      system
      home.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.vicenzo = {};
          sharedModules = import_ ./home;
          extraSpecialArgs = {inherit (inputs) devenv ;};
        };
      }
    ];
    sharedOverlays = [ utils.overlay neovim.overlay nur.overlay ];
    outputsBuilder = x: let
      pkgs = x.nixpkgs;
 #     shell = import ./shell {inherit pkgs inputs devenv;};
      fmt = pkgs.nixpkgs-fmt;
    in {
#      devShells = shell;
      formatter = fmt;
    };
    channelsConfig = import ./system/nix {inherit nixpkgs;};
    import_ = name:
      map (i: "${name}/${i}")
      (builtins.attrNames (builtins.readDir name));
  in
    utils.lib.mkFlake {
      inherit self inputs sharedOverlays channelsConfig outputsBuilder;
      supportedSystems = ["x86_64-linux"];
      hosts.nixos = {inherit modules;};
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home.url = "github:nix-community/home-manager";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
  };
}
