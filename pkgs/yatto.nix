{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
}:
buildGoModule {
  pname = "yatto";
  version = "v0.15.0";

  src = fetchFromGitHub {
    owner = "handlebargh";
    repo = "yatto";
    rev = "v0.15.0";
    sha256 = "sha256-KiXw3fmNf7mRuUOLg0xqlKgbyx0LaEpqaSAHeqqzW4M=";
  };

  vendorHash = "sha256-WKUVgJjvCcI5xoK69vY41NgNDjTcDDqleSgSzNBrCqI=";

  meta = with lib; {
    mainProgram = "yatto";
    description = "";
    homepage = "https://github.com/handlebargh/yatto";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
