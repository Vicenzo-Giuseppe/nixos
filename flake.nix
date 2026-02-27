{
  outputs =
    inputs@{
      self,
      home,
      nixpkgs,
      microvm,
      utils,
      ...
    }:
    with builtins;
    let
      Config = fromTOML (readFile ./config.toml);
      inherit (Config) system host user;
      channelsConfig = import ./systems/nix-config.nix { inherit nixpkgs user; };
      sharedOverlays = import ./systems/overlays.nix { inherit pkgs inputs; };
      hosts = import ./systems {
        inherit
          host
          system
          user
          Config
          ;
      };
      hostDefaults = {
        modules = import ./systems/hm-manager.nix {
          inherit
            home
            host
            user
            system
            inputs
            Config
            ;
        };
        extraArgs = { inherit user; };
      };
      outputsBuilder =
        x:
        let
          formatter =
            (import ./systems/formatters.nix {
              inherit inputs;
              pkgs = x.nixpkgs;
            }).config.build.wrapper;

          mkMicroVm =
            name: configModule:
            (nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                microvm.nixosModules.microvm
                configModule
              ];
            }).config.microvm.declaredRunner;
          Packages = import ./lib/packages.nix {
            inherit (nixpkgs) lib;
            inherit inputs user;
            home-lib = home.lib;
            pkgs = nixpkgs.legacyPackages.${system};
          };

          packages = {
            zv = Packages "mnw";
            firefox = Packages "firefox";
            opencode = Packages "opencode";
            vm = mkMicroVm "default-vm" (
              import ./systems/vm.nix {
                inherit inputs config user;
                pkgs = nixpkgs;
              }
            );
            # "${host}-vm" = self.nixosConfigurations.${host}.config.system.build.nixos-shell; # requires --impure and fucks up sops lib/packages.nix work
          };
        in
        {
          inherit packages formatter;
        };
    in
    utils.lib.mkFlake {
      inherit
        self
        inputs
        sharedOverlays
        channelsConfig
        outputsBuilder
        hostDefaults
        hosts
        ;
      supportedSystems = [ system ];
    };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
    spicetify.url = "github:Gerg-L/spicetify-nix";
    nixos-shell.url = "github:Mic92/nixos-shell";
    opencode.url = "github:sst/opencode/";
    treefmt.url = "github:numtide/treefmt-nix";
    mnw.url = "github:Gerg-L/mnw";
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home";
      };
    };
    sops.url = "github:Mic92/sops-nix";
    bun2nix.url = "github:nix-community/bun2nix";
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
