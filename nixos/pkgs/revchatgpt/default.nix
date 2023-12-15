{
  pkgs,
  lib,
}:
with pkgs.python38Packages;
  buildPythonPackage rec {
    pname = "revChatGPT";
    version = "3.1.5";
    propagatedBuildInputs = [
      prompt-toolkit
      pysocks
      requests
      pkgs.python.tiktoken
      httpx-socks
    ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-/AmSvMvcP8nlwIFTszamPwUBbA9XKVMhfGADOJTlxc0=";
    };

    doCheck = false;

    meta = with lib; {
      homepage = "";
      description = ''
      '';
      license = licenses.mit;
    };
  }
