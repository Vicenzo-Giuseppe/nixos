{
  description = "Vicenzo's Hive-based Nix configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixago = {
      inputs = {
        nixago-exts = {
          follows = "";
        };
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/nixago";
    };
    std = {
      url = "github:divnix/std";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "devshell";
        nixago.follows = "nixago";
      };
    };
    hive = {
      url = "github:divnix/hive";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home2405 = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs2405";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs2405";
      inputs.home-manager.follows = "home2405";
    };
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home";
      };
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spacebot-src = {
      url = "github:spacedriveapp/spacebot";
      flake = false;
    };
    spacebot = {
      #url = "path:/home/vicenzo/sources/spacebot";
      url = "github:skulldogged/spacebot-nix";
      inputs.spacebot-src.follows = "spacebot-src";
    };
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
    spicetify.url = "github:Gerg-L/spicetify-nix";
    treefmt.url = "github:numtide/treefmt-nix";
    mnw.url = "github:Gerg-L/mnw";
    sops.url = "github:Mic92/sops-nix";
    bun2nix.url = "github:nix-community/bun2nix";
    home-manager.follows = "home";
    hyprland.url = "github:hyprwm/Hyprland";
    warp.url = "path:/home/vicenzo/sources/warp";
    caelestia-src.url = "path:/home/vicenzo/sources/caelestia";
    spacedrive.url = "path:/home/vicenzo/sources/spacedrive";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };
  outputs =
    inputs@{
      std,
      nixpkgs,
      hive,
      self,
      ...
    }:
    with nixpkgs.lib;
    let
      hostSystem = "x86_64-linux";
      blockTypes = attrsets.mergeAttrsList [
        std.blockTypes
        hive.blockTypes
      ];
      mkPkgs =
        system:
        let
          channelsConfig = import ./home/nix-config.nix {
            inherit (inputs) nixpkgs;
          };
          sharedOverlays = import ./home/overlays.nix { inherit inputs; };
        in
        import inputs.nixpkgs {
          inherit system;
          config = channelsConfig;
          overlays = sharedOverlays;
        };
      targetDefs =
        (import ./lib/targets.nix {
          inherit inputs;
          names = [
            "notebook"
            "vm"
            "phone"
          ];
        }).defs;
      nixosConfigurations = mapAttrs (_: value: value.configuration) (
        filterAttrs (_: value: value.kind == "nixos") targetDefs
      );
      nixOnDroidConfigurations = mapAttrs (_: value: value.configuration) (
        filterAttrs (_: value: value.kind == "nix-on-droid") targetDefs
      );
      packageOutputs =
        (import ./programs/run.nix {
          inherit inputs;
          cell = { };
        })
        // (import ./pkgs/packages.nix {
          inherit inputs;
          cell = { };
        });
      devShellOutputs = import ./programs/shell.nix {
        inherit inputs;
        cell = { };
      };
      grown =
        std.growOn
          {
            inherit inputs;
            systems = [ hostSystem ];
            cellsFrom = std.incl ./. [
              "programs"
              "pkgs"
            ];
            cellBlocks = with blockTypes; [
              (functions "module")
              (functions "config")
              (devshells "shell")
              (installables "packages")
              (installables "run")
            ];
          }
          {
            packages.${hostSystem} = packageOutputs;

            devShells.${hostSystem} = devShellOutputs;

            formatter = {
              ${hostSystem} =
                (import ./home/formatters.nix {
                  inherit inputs;
                  pkgs = mkPkgs hostSystem;
                }).config.build.wrapper;
            };

            inherit nixosConfigurations nixOnDroidConfigurations;
          };
    in
    removeAttrs grown [
      "__functor"
      hostSystem
    ];
}
