{
  lib,
  pkgs,
  inputs,
  enabled,
  ...
}: let
  textEditor = "nvim.desktop";
  archiveManager = "org.gnome.FileRoller.desktop";
  fileManager = "Spacedrive.desktop";
  webBrowser = "firefox.desktop";
  magnetHandler = "caelestia-downloads.desktop";
  caelestiaDownloadLink = pkgs.writeShellScriptBin "caelestia-download-link" ''
    if [ "$#" -eq 0 ]; then
      exit 0
    fi

    caelestia shell -d >/dev/null 2>&1 || true

    for uri in "$@"; do
      if [ -z "$uri" ]; then
        continue
      fi

      success=""
      for _ in 1 2 3 4 5; do
        if caelestia shell downloads add "$uri" >/dev/null 2>&1; then
          success=1
          break
        fi
        ${pkgs.coreutils}/bin/sleep 0.2
      done

      if [ -z "$success" ]; then
        exit 1
      fi
    done
  '';

  archiveMimeTypes = [
    "application/zip"
    "application/x-zip"
    "application/x-zip-compressed"
    "application/vnd.rar"
    "application/x-rar"
    "application/x-rar-compressed"
    "application/x-7z-compressed"
    "application/x-tar"
    "application/x-compressed-tar"
    "application/gzip"
    "application/x-gzip"
    "application/x-bzip"
    "application/x-bzip2"
    "application/x-xz"
    "application/zstd"
    "application/x-zstd-compressed-tar"
  ];

  markdownMimeTypes = [
    "text/markdown"
    "text/x-markdown"
    "application/markdown"
    "application/x-markdown"
  ];

  magnetMimeTypes = [
    "x-scheme-handler/magnet"
    "application/x-bittorrent"
  ];

  webMimeTypes = [
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "text/html"
    "application/xhtml+xml"
  ];

  mkDefaults = app: mimeTypes:
    builtins.listToAttrs (
      builtins.map (mime: {
        name = mime;
        value = [app];
      })
      mimeTypes
    );
in {
  home = lib.mkIf enabled {
    home.packages = [
      pkgs.file-roller
      caelestiaDownloadLink
    ];

    home.file.".local/share/icons/hicolor/512x512/apps/dev.warp.WarpOss.png".source = "${inputs.warp}/app/channels/oss/icon/no-padding/512x512.png";

    xdg = {
      enable = true;
      desktopEntries."dev.warp.WarpOss" = {
        name = "Warp";
        genericName = "Terminal";
        comment = "User Terminal";
        exec = "warp-oss %U";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
        mimeType = [
          "x-scheme-handler/warposs"
        ];
        icon = "dev.warp.WarpOss";
        settings = {
          StartupWMClass = "dev.warp.WarpOss";
        };
      };
      desktopEntries.caelestia-downloads = {
        name = "Caelestia Downloads";
        genericName = "Open links in Caelestia Downloads";
        exec = "caelestia-download-link %U";
        terminal = false;
        noDisplay = true;
        mimeType = magnetMimeTypes;
      };
      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          _ = "\$HOME/Code";
        };
      };
      mimeApps = {
        enable = true;

        associations.added =
          (mkDefaults archiveManager archiveMimeTypes)
          // (mkDefaults webBrowser webMimeTypes)
          // (mkDefaults textEditor markdownMimeTypes)
          // (mkDefaults magnetHandler magnetMimeTypes)
          // {
            "text/plain" = [textEditor];
          };

        defaultApplications =
          (mkDefaults archiveManager archiveMimeTypes)
          // (mkDefaults webBrowser webMimeTypes)
          // (mkDefaults textEditor markdownMimeTypes)
          // (mkDefaults magnetHandler magnetMimeTypes)
          // {
            "text/plain" = [textEditor];
            "inode/directory" = [fileManager];
          };
      };
    };
  };
  nixos = lib.mkIf enabled {};
}
