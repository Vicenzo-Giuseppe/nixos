{
  user,
  ...
}: {
  output = {
    serviceName = "screenpipe";
    dataDir = "/home/${user}/.screenpipe";
    port = 3030;

    webviewHost = "127.0.0.1";
    webviewPort = 3031;
    webviewAllowRawSql = false;
    webviewMediaScanLimit = 700;
    webviewExtraMediaDirs = [];

    # Audio is intentionally not disabled: the dashboard now exposes audio
    # device status, transcript search, and local playable media files.
    extraArgs = [
      "--use-all-monitors"
    ];
  };
}
