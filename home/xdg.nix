{...}: let
  firefox = "firefox.desktop";
  torrent = "org.qbittorrent.qBittorrent.desktop";
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "\$HOME/Desktop";
      createDirectories = true;
      extraConfig = {torrent = "\$HOME/Torrents";};
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/octet-stream" = [firefox];
        "application/x-bittorrent" = [torrent];
        "application/x-extension-htm" = [firefox];
        "application/x-extension-html" = [firefox];
        "application/x-extension-shtml" = [firefox];
        "application/x-extension-xhtml" = [firefox];
        "application/x-extension-xht" = [firefox];
        "application/xhtml+xml" = [firefox];
        "text/html" = [firefox];
        "text/plain" = [firefox];
        "x-scheme-handler/chrome" = [firefox];
        "x-scheme-handler/ftp" = [firefox];
        "x-scheme-handler/http" = [firefox];
        "x-scheme-handler/https" = [firefox];
        #       "image/jpeg" = [ "org.gnome.eog.desktop" ];
        #       "image/png" = [ "org.gnome.eog.desktop" ];
        #       "message/rfc822" = [ "userapp-Thunderbird.desktop" ];
        #       "video/mp4" = [ "vlc.desktop" ];
        #       "application/pdf" = [ "org.gnome.Evince.desktop" ];
        #       "x-scheme-handler/mailto" = [ "userapp-Thunderbird.desktop" ];
        #       "x-scheme-handler/msteams" = [ "teams.desktop" ];
        #       "x-scheme-handler/tg" = [ "userapp-Telegram Desktop-JBKFU0.desktop" ];
      };
    };
  };
}
