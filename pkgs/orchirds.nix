{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  dbus-glib,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk2,
  libdbusmenu,
  libdbusmenu-gtk2,
  libcap,
  libdrm,
  libnotify,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxshmfence,
  libXtst,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
  ...
}: let
  pname = "orchids";
  version = "1.0.9";

  src = fetchurl {
    url = "https://slelguoygbfzlpylpxfs.supabase.co/storage/v1/object/public/desktop-artifact/public/v${version}/linux/orchids.AppImage";
    hash = "sha256-ZIRhLsSISQdNSHwXQ+rzYu4gy/ZElDK/bXvY7WF5Zdg=";
  };

  extracted = appimageTools.extractType2 {
    inherit pname version src;
  };

  runtimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    dbus-glib
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    gtk3
    libdbusmenu
    libdbusmenu-gtk2
    libcap
    libdrm
    libnotify
    libsecret
    libuuid
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxkbfile
    libxrandr
    libxrender
    libxshmfence
    libXtst
    mesa
    nspr
    nss
    pango
    systemd
  ];
in
  stdenv.mkDerivation {
    inherit pname version;
    dontUnpack = true;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    autoPatchelfIgnoreMissingDeps = [
      "libc.musl-x86_64.so.1"
    ];

    buildInputs = runtimeLibs;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin $out/share/applications
      cp -r ${extracted}/* $out/opt/${pname}/
      chmod -R u+w $out/opt/${pname}

      makeWrapper $out/opt/${pname}/orchids $out/bin/orchids \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

      install -Dm644 $out/opt/${pname}/orchids.desktop \
        $out/share/applications/orchids.desktop
      substituteInPlace $out/share/applications/orchids.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=orchids %U'

      for size in 16 24 32 48 64 128 256 512; do
        install -Dm644 $out/opt/${pname}/orchids.png \
          $out/share/icons/hicolor/''${size}x''${size}/apps/orchids.png
      done

      runHook postInstall
    '';

    meta = with lib; {
      description = "Orchids AI app builder desktop client";
      homepage = "https://www.orchids.app/";
      license = licenses.unfree;
      mainProgram = "orchids";
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
