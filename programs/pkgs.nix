{
  pkgs,
  inputs,
  lib,
  enabled,
  ...
}:
let
  inherit (inputs) warp;
  coreCli = with pkgs; [
    git
    gh
    ripgrep
    fd
    curl
    tree-sitter
    jq
    unzip
  ];
  devTooling = with pkgs; [
    statix
    biome
    nixd
    nil
    devenv
    nix-direnv
    uv
    vtsls
    kotlin-language-server
    kotlin-debug-adapter
    ktlint
    python3
    lua
  ];
  desktopApps = with pkgs; [
    affine
    riseup-vpn
    lutris
    bottles
    hydralauncher
    cage
  ];
  hardwareAndGraphics = with pkgs; [
    glib
    gdk-pixbuf
    gdtoolkit_4
    nvtopPackages.full
    libvdpau-va-gl
    intel-media-driver
    intel-gpu-tools
    intel-vaapi-driver
    lenovo-legion
  ];
  nixAndShellExtras = with pkgs; [
    sops
    fup-repl
    luajitPackages.magick
    python313Packages.sixel
  ];
  customPkgs = with pkgs; [
    dotenvhub
    hwinfo
    hwinfo-tui
    runal
    yatto
  ];
  externalPkgs = [
    warp.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  optionalNixAi =
    if inputs ? nix-ai-tools
    then
      with inputs.nix-ai-tools.packages.x86_64-linux; [
        #   crush
      ]
    else [ ];
  homePackages =
    coreCli
    ++ devTooling
    ++ desktopApps
    ++ hardwareAndGraphics
    ++ nixAndShellExtras
    ++ customPkgs
    ++ externalPkgs
    ++ optionalNixAi;
in
{
  home = lib.mkIf enabled {
    home.packages = homePackages;
  };
  nixos = lib.mkIf enabled { };
}
