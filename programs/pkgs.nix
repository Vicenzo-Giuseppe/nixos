{
  pkgs,
  inputs,
  lib,
  enabled,
  ...
}: let
  inherit (inputs) llm-agents warp;
  hydralauncher = let
    pname = "hydralauncher";
    version = "3.9.7";
    src = pkgs.fetchurl {
      url = "https://github.com/hydralauncher/hydra/releases/download/v${version}/hydralauncher-${version}.AppImage";
      hash = "sha256-VQYgmsWS/5naSlcbTeIUkFb79lwlVO1HZbf23TDsHH0=";
    };
    appimageContents = pkgs.appimageTools.extractType2 {inherit pname src version;};
  in
    pkgs.appimageTools.wrapType2 {
      inherit pname src version;
      extraInstallCommands = ''
        install -Dm644 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/hydralauncher.png \
          $out/share/icons/hicolor/512x512/apps/hydralauncher.png

        install -Dm644 ${appimageContents}/hydralauncher.desktop \
          $out/share/applications/hydralauncher.desktop
        substituteInPlace $out/share/applications/hydralauncher.desktop \
          --replace-fail 'Exec=AppRun' "Exec=$out/bin/hydralauncher"
      '';

      meta =
        pkgs.hydralauncher.meta
        // {
          changelog = "https://github.com/hydralauncher/hydra/releases/tag/v${version}";
        };
    };
  hydralauncherFixed = pkgs.symlinkJoin {
    name = "hydralauncher-fixed";
    paths = [hydralauncher];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm -f $out/bin/hydralauncher
      rm -f $out/share/applications/hydralauncher.desktop

      makeWrapper ${hydralauncher}/bin/hydralauncher $out/bin/hydralauncher \
        --set ELECTRON_ENABLE_WAYLAND 0 \
        --set ELECTRON_OZONE_PLATFORM_HINT x11 \
        --set OZONE_PLATFORM x11 \
        --set GDK_BACKEND x11 \
        --set QT_QPA_PLATFORM xcb \
        --unset WAYLAND_DISPLAY \
        --add-flags "--disable-features=UseOzonePlatform --ozone-platform=x11"

      cp ${hydralauncher}/share/applications/hydralauncher.desktop $out/share/applications/hydralauncher.desktop
      substituteInPlace $out/share/applications/hydralauncher.desktop \
        --replace-fail 'Exec=${hydralauncher}/bin/hydralauncher --no-sandbox %U' "Exec=$out/bin/hydralauncher --no-sandbox %U"
    '';
  };
  coreCli = with pkgs; [
    git
    unar
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.code
    llm-agents.packages.x86_64-linux.gemini-cli
    yt-dlp
    ffmpeg
    nodejs
    bun
    discord
    vlc
    gh
    ripgrep
    fd
    curl
    wireguard-tools
    tree-sitter
    jq
    signal-cli
    google-chrome
    fluffychat
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
    hydralauncherFixed
    cage
    orchirds
    screenpipe
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
  homePackages =
    coreCli
    ++ devTooling
    ++ desktopApps
    ++ hardwareAndGraphics
    ++ nixAndShellExtras
    ++ customPkgs
    ++ externalPkgs;
in {
  home = lib.mkIf enabled {
    home.packages = homePackages;
  };
  nixos = lib.mkIf enabled {};
}
