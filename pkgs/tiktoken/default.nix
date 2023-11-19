{
  pkgs,
  fetchPypi,
  libiconv,
  rustPlatform,
}:
with pkgs.python38Packages;
  buildPythonPackage rec {
    pname = "tiktoken";
    version = "0.3.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-JHak9NKSk3YtwzINUNhmIC1+HFYqw3inhd3lEFfc714=";
    };

    cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src patches;
      name = "${pname}-${version}";
      hash = "sha256-Y9c0f39WBcSWBOSP/Wx04sq9flztWJBHQAS2Y6YU1QA=";
    };

    doCheck = false;

    patches = [./Cargo.lock.patch];

    nativeBuildInputs = with rustPlatform; [
      cargoSetupHook
      rust.cargo
      rust.rustc
      setuptools-rust
    ];

    buildInputs = [
      libiconv
    ];

    propagatedBuildInputs = with pkgs; [
      regex
      requests
    ];
  }
