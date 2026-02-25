# programs/mnw/default.nix
{
  lib,
  pkgs ? {},
  enabled ? true,
  ...
}:
with pkgs; let
  lvimName = "zv";
  statusline = pkgs.vimUtils.buildVimPlugin {
    name = "heirline";
    src = ./lua/plugins/statusline;
    doCheck = false;
  };
  homeConfig = {
    programs.mnw = {
      enable = true;
      initLua = ''
        require("lazy-cfg")
        require("config")
        require("keys")
      '';
      aliases = [
        lvimName
        "zvim"
      ];
      desktopEntry = true;
      neovim = neovim-unwrapped;
      extraBinPath = [
        imagemagick
        ffmpeg
        ghostscript
      ];
      appName = lvimName;
      plugins = {
        start = with vimPlugins; [
          nvim-web-devicons
          edgy-nvim
          lazy-nvim
          LazyVim
          nvim-window-picker
          oxocarbon-nvim
          statusline
        ];
        dev.myconfig = {
          pure = ./.;
          impure = "/home/vicenzo/.config/zv";
        };
        opt = with vimPlugins; [
          nvim-navbuddy
          bufferline-nvim
          showkeys
          markview-nvim
          lsp-progress-nvim
          # {
          #   pname = "heirline";
          #
          #   src = fetchFromGitHub {
          #     owner = "rebelot";
          #     repo = "heirline.nvim";
          #     rev = "fae936abb5e0345b85c3a03ecf38525b0828b992";
          #     hash = "sha256-kHoaeULWI+NrLp0am0DSKRKeA1vZIg4pt5NxZuFUDvY=";
          #   };
          # }
          {
            pname = "prompt";

            src = fetchFromGitHub {
              owner = "robcmills";
              repo = "prompt.nvim";
              rev = "41752e1c5fdeb3ebdabf3701acc4fd0f9bcacc23";
              hash = "sha256-LdHB4Bp/ardkVnrZ3gveVcMDk+jUuhpdoNQraA/CGUA=";
            };
          }
          codecompanion-nvim
        ];
      };
    };
  };
in {
  home = lib.mkIf enabled homeConfig;
  nixos = lib.mkIf enabled {};
  config = homeConfig;
}
