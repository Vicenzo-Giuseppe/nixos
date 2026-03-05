{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  gdk-pixbuf,
  glib,
  gst_all_1,
  libsoup_3,
  webkitgtk_4_1,
  xdotool,
}:
let
  pname = "spacedrive";
  version = "v2.0.0-alpha.2";

  src = fetchurl {
    url = "https://github.com/spacedriveapp/spacedrive/releases/download/${version}/Spacedrive-linux-x86_64.deb";
    hash = "sha256-KzRPBtyX5x4ZLlZd6SgAS/cy/7irXt7v+b3Yuq9GETo=";
  };
in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    ;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  # Depends: libc6, libxdo3, libwebkit2gtk-4.1-0, libgtk-3-0
  # Recommends: gstreamer1.0-plugins-ugly
  # Suggests: gstreamer1.0-plugins-bad
  buildInputs = [
    xdotool
    glib
    libsoup_3
    webkitgtk_4_1
    gdk-pixbuf
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/share $out/
    cp -r usr/lib $out/
    cp -r usr/bin $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Open source file manager, powered by a virtual distributed filesystem";
    homepage = "https://www.spacedrive.com";
    changelog = "https://github.com/spacedriveapp/spacedrive/releases/tag/${version}";
    license = licenses.agpl3Plus;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "spacedrive";
  };
}
