{inputs, ...}: let
  inherit
    (inputs)
    utils
    bun2nix
    neovim
    ;
in [
  utils.overlay
  bun2nix.overlays.default
  (
    final: prev: {
      # openldap's upstream syncrepl test is intermittently failing in this
      # environment and blocks unrelated desktop packages like lutris/bottles.
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });

      # Bottles 64.0 is already upstream while the pinned nixpkgs revision is
      # still on 63.2, so carry a small source override until nixpkgs moves.
      bottles-unwrapped = prev.bottles-unwrapped.overrideAttrs (_: rec {
        version = "64.0";
        src = prev.fetchFromGitHub {
          owner = "bottlesdevs";
          repo = "bottles";
          tag = version;
          hash = "sha256-DRwXzDzvKW1uYyPCXHg+5s1smKjp8Dq6lSLbi9tHR0Q=";
        };
      });

      vimPlugins = prev.vimPlugins // import ../lib/vim-plugins.nix {
        pkgs = final;
        vimPlugins = prev.vimPlugins;
      };
    }
  )
  (
    final: prev:
      import ../pkgs {
        inherit inputs;
        pkgs = final;
      }
  )
]
