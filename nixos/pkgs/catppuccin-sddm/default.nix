{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  pname = "catppuccin-sddm";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "sddm";
    rev = "bde6932e1ae0f8fdda76eff5c81ea8d3b7d653c0";
    sha256 = "ceaK/I5lhFz6c+UafQyQVJIzzPxjmsscBgj8130D4dE=";
  };
  phases = "buildPhase";
  buildCommand = ''
    mkdir -p $out/share/sddm/themes/
    cp -r $src/src/catppuccin-mocha $out/share/sddm/themes/catppuccin-mocha
    chmod -R +w $out/share/sddm/themes/catppuccin-mocha
  '';
  meta = {
    description = "sddm-theme";
  };
}
