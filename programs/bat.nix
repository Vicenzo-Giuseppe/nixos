{
  pkgs,
  lib,
  enabled,
  ...
}: let
  theme = "Catppuccin Mocha";
in {
  home = lib.mkIf enabled {
    programs.bat = {
      enable = true;
      config.theme = theme;
      themes.${theme} = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
          sha256 = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
        };
        file = "themes/${theme}.tmTheme";
      };
    };
    home.packages = with pkgs; [bat-extras.batgrep];
  };
  nixos =
    lib.mkIf enabled {
    };
}
