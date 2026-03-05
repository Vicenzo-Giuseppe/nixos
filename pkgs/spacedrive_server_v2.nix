{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  ffmpeg_7,
  libheif,
  openssl,
  stdenv,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "spacedrive-server-v2";
  version = "v2.0.0-alpha.2";

  src = fetchurl {
    url = "https://github.com/spacedriveapp/spacedrive/releases/download/${finalAttrs.version}/sd-server-linux-x86_64.tar.gz";
    hash = "sha256-H6qFe0dPH0HWp3saD1MLiNLi6mdKfkAK6iNxU0yBHvY=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    ffmpeg_7
    libheif
    openssl
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 sd-server-linux-x86_64 $out/bin/sd-server

    runHook postInstall
  '';

  meta = with lib; {
    description = "Spacedrive v2 headless server (RPC endpoint)";
    homepage = "https://github.com/spacedriveapp/spacedrive";
    changelog = "https://github.com/spacedriveapp/spacedrive/releases/tag/${finalAttrs.version}";
    license = licenses.agpl3Plus;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "sd-server";
  };
})
