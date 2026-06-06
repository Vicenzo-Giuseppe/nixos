{
  pkgs,
  ...
}: let
  screenpipePackage = pkgs.screenpipe;
  webviewPackage = pkgs.writeShellApplication {
    name = "screenpipe-webview";
    runtimeInputs = [
      (pkgs.bun or pkgs.bun-bin)
      screenpipePackage
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
      export SCREENPIPE_WEBVIEW_ROOT=${./web}
      exec bun run ${./web}/src/server.mjs "$@"
    '';
  };
in {
  package = screenpipePackage;
  inherit webviewPackage;

  runtimeInputs = [
    pkgs.tesseract
  ];

  homePackages = [
    screenpipePackage
    pkgs.tesseract
    webviewPackage
  ];
}
