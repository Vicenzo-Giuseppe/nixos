{
  lib,
  pkgs,
  writeShellApplication,
}: let
  version = "0.18.10";
in
  writeShellApplication {
    name = "screenpipe-mcp";
    runtimeInputs = [
      pkgs.nodejs
    ];
    text = ''
      exec ${pkgs.nodejs}/bin/npx -y screenpipe-mcp@${version} "$@"
    '';

    meta = {
      description = "Upstream Screenpipe MCP wrapper pinned to npm release";
      homepage = "https://github.com/screenpipe/screenpipe/tree/main/packages/screenpipe-mcp";
      license = lib.licenses.mit;
      mainProgram = "screenpipe-mcp";
      platforms = lib.platforms.all;
    };
  }
