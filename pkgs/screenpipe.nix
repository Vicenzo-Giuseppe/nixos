{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  libgbm,
  libxau,
  libxcb,
  libxdmcp,
  makeWrapper,
  libGL,
  libpulseaudio,
  openblas,
  openssl,
  stdenv,
  wayland,
  xz,
}: let
  version = "0.4.6";
  src = fetchurl {
    url = "https://registry.npmjs.org/@screenpipe/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-c6L9AWhfjGnVsm93vpiPX09Vsy/7IV1lMrV6FDXQG6Q=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "screenpipe";
    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      libgbm
      libGL
      libpulseaudio
      openblas
      openssl
      stdenv.cc.cc.lib
      wayland
      xz
      libxau
      libxdmcp
      libxcb
    ];

    unpackPhase = ''
      runHook preUnpack
      tar -xzf $src
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp package/bin/screenpipe $out/bin/screenpipe
      chmod +x $out/bin/screenpipe
      runHook postInstall
    '';

    meta = {
      description = "AI that knows everything you've seen, said, or heard";
      homepage = "https://screenpi.pe";
      license = lib.licenses.mit;
      mainProgram = "screenpipe";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  }
