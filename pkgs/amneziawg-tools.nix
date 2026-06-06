{
  stdenv,
  lib,
  fetchFromGitHub,
  bash,
  amneziawg-go,
  coreutils,
  gawk,
  gnugrep,
  iproute2,
  iptables,
  makeWrapper,
  nftables,
  openresolv,
  procps,
}:
stdenv.mkDerivation rec {
  pname = "amneziawg-tools";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "amnezia-vpn";
    repo = pname;
    rev = "master";
    hash = "sha256-pHmuxlrbTqjwRrB7BShdC4ENw3iVQRRLH+Z2w8x+KeE=";
  };

  nativeBuildInputs = [makeWrapper];

  buildPhase = ''
    runHook preBuild
    make -C src
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C src install \
      PREFIX=$out \
      SYSCONFDIR=$out/etc \
      BINDIR=$out/bin \
      MANDIR=$out/share/man \
      WITH_WGQUICK=yes \
      WITH_SYSTEMDUNITS=no \
      WITH_BASHCOMPLETION=no

    wrapProgram $out/bin/awg-quick \
      --prefix PATH : ${lib.makeBinPath [
      amneziawg-go
      bash
      coreutils
      gawk
      gnugrep
      iproute2
      iptables
      nftables
      openresolv
      procps
    ]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Official AmneziaWG command-line tools including awg and awg-quick";
    homepage = "https://github.com/amnezia-vpn/amneziawg-tools";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    mainProgram = "awg";
  };
}
