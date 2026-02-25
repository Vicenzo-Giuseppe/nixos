{
  lib,
  enabled,
  ...
}: let
in {
  home = lib.mkIf enabled {
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          _ = "\$HOME/Code";
        };
      };
      mimeApps = {
        enable = true;
        #   defaultApplications = {
        #     "application/x-msdownload" = [ "com.usebottles.bottles.desktop" ];
        #     "application/x-ms-dos-executable" = [ "com.usebottles.bottles.desktop" ];
        #     "application/x-wine-extension-exe" = [ "com.usebottles.bottles.desktop" ];
        #   };
      };
    };
  };
  nixos = lib.mkIf enabled {};
}
