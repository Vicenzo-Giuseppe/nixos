{
  lib,
  pkgs,
  writeShellApplication,
  fetchFromGitHub,
}: let
  python = pkgs.python3.withPackages (
    ps: with ps; [mcp]
  );

  src = fetchFromGitHub {
    owner = "stefanoamorelli";
    repo = "hyprmcp";
    rev = "13d5195e6a474078183cb031771be7a71b330bb6";
    hash = "sha256-B6YwMm8yGLqahYDxgDEWk0Te2QmQPdCsIQ4+lqu6s44=";
  };
in
  writeShellApplication {
    name = "hyprmcp";
    runtimeInputs = [
      python
      pkgs.hyprland
    ];
    text = ''
      exec python ${src}/hyprmcp/server.py "$@"
    '';

    meta = {
      description = "Unofficial MCP server exposing Hyprland hyprctl functionality";
      homepage = "https://github.com/stefanoamorelli/hyprmcp";
      license = lib.licenses.mit;
      mainProgram = "hyprmcp";
      platforms = lib.platforms.linux;
    };
  }
