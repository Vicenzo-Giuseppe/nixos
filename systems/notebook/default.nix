{...}: let
  imports = [
    ./hardware.nix
    ./filesystem.nix
    ./loq-15IRH8.nix
  ];
in {
  inherit imports;
}
