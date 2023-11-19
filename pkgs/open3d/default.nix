{
  stdenv,
  libX11,
  autoPatchelfHook,
  libcxx,
  udev,
  libGL,
}: let
  src = builtins.fetchTarball {
    url = "https://github.com/isl-org/Open3D/releases/download/v0.16.0/open3d-devel-linux-x86_64-cxx11-abi-0.16.0.tar.xz";
  };
  deb = builtins.fetchurl {
    url = "https://github.com/isl-org/Open3D/releases/download/v0.16.0/open3d-app-0.16.0-Ubuntu.deb";
  };
in
  stdenv.mkDerivation {
    pname = "open3d";
    version = "0.16.1";

    inherit src;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      libGL
      libcxx
      libX11
      udev
    ];

    runtimeDependencies = [
      libGL
    ];

    installPhase = ''
      cp -a . $out
      ar x ${deb}
      tar -xzvf data.tar.gz
      cp -a usr/local/* $out
      substituteInPlace $out/bin/Open3D --replace /usr/local $out
    '';
  }
