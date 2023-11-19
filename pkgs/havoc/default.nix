{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
}:
stdenv.mkDerivation {
  pname = "havoc";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "HavocFramework";
    repo = "Havoc";
    rev = "7a48a0f";
    sha256 = "sha256-gTJy1R5wwlcEsVpzAbOeoUy+251wy2IYMViJi2JD9bM=";
  };

  phases = ["installPhase"];
  nativeBuildInputs = with pkgs; [cmake python3];
  buildInputs = with pkgs; [spdlog libsForQt5.full];
  installPhase = ''
    cmake $src/Client
    mkdir -p $out/Havoc
    cp -r $src/Client/Havoc $out/Havoc
  '';

  meta = with lib; {
    description = "";
    homepage = "";
    license = with licenses; [gpl3Plus lgpl3Plus];
    platforms = platforms.all;
  };
}
