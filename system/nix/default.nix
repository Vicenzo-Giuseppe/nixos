{nixpkgs}: {
  permittedInsecurePackages = [
    "python-2.7.18.6"
    "qtwebkit-5.212.0-alpha4"
    "electron-12.2.3"
  ];
  allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) [
      "google-chrome"
      "steam-original"
      "steam-run"
      "steamcmd"
      "lunar-client"
      "discord"
      "steam"
      "flagfox"
    ];
}
