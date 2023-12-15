{
  outputs = inputs @ {
    self,
    home,
    nixpkgs,
    utils,
    devenv,
    wsl,
    neovim,
    ...
  }: let
    host = "wsl";
    user = "vicenzo";
    supportedSystems = ["x86_64-linux"];
    modules = [
      home.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user} = {};
          sharedModules = import_ ./home;
          extraSpecialArgs = {inherit host user;};
        };
      }
    ];
    sharedOverlays = [
      overlay
      utils.overlay
      neovim.overlay
    ];
    x = builtins;
    import_ = name:
      map (i: "${name}/${i}")
      (x.attrNames (x.readDir name));
    overlay = y: z: let
      dirContents = x.readDir ./pkgs;
      genPackage = name: {
        inherit name;
        value = y.callPackage (./pkgs + "/${name}") {};
      };
      names = x.attrNames dirContents;
    in
      x.listToAttrs (map genPackage names);
    outputsBuilder = x: let
      pkgs = x.nixpkgs;
      shell = import ./shell {inherit pkgs inputs devenv;};
    in {
      devShells = shell;
      formatter = pkgs.alejandra;
    };
    channelsConfig = import ./nix {inherit nixpkgs user;};
    hosts = {
      wsl = {
        modules = [
          wsl.nixosModules.wsl
          ./systems/wsl.nix
        ];
      };
    };
    hostDefaults = {
      inherit modules;
      channelName = "unstable";
      extraArgs = {inherit user;};
    };
  in
    utils.lib.mkFlake {
      inherit self inputs sharedOverlays channelsConfig outputsBuilder supportedSystems hosts hostDefaults;
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home.url = "github:nix-community/home-manager";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    devenv.url = "github:cachix/devenv";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    wsl.url = "github:nix-community/NixOS-WSL";
  };
}
