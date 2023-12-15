{
  pkgs,
  lib,
}: let
  llama-cpp-pin = pkgs.fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "e7f6997f897a18b6372a6460e25c5f89e1469f1d";
    hash = "sha256-vxtBq4PeYkRWML6IJhbhDhdyBfaLSzCg1rNu2ozuPAk=";
  };
in
  with pkgs.python310Packages;
    buildPythonPackage rec {
      pname = "llama-cpp-python";
      version = "0.1.33";

      format = "pyproject";
      src = pkgs.fetchFromGitHub {
        owner = "abetlen";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-sXAFQmo6qGenpY3yQUsAHeo0DZAmSQoPDQniOmA5MP8=";
      };

      preConfigure = ''
        cp -r ${llama-cpp-pin}/. ./vendor/llama.cpp
        chmod -R +w ./vendor/llama.cpp
      '';
      preBuild = ''
        cd ..
      '';

      nativeBuildInputs = [
        pkgs.cmake
        pkgs.ninja
        poetry-core
        scikit-build
        setuptools
      ];

      propagatedBuildInputs = [
        typing-extensions
      ];

      pythonImportsCheck = ["llama_cpp"];

      meta = with lib; {
        description = "A Python wrapper for llama.cpp";
        homepage = "https://github.com/abetlen/llama-cpp-python";
        license = licenses.mit;
        maintainers = with maintainers; [jpetrucciani];
      };
    }
