{
  lib,
  pkgs ? {},
  packageConfig,
  aliases ? [
    "zv"
    "zvim"
  ],
  appName ? "zv",
  enabled ? true,
  ...
}:
with pkgs; let
  inherit (packageConfig)
    neovim
    vimPlugins
    extraBinPath
    statusline
    ;
  homeConfig = {
    programs.mnw = {
      enable = true;
      initLua = ''
        require("lazy-cfg")
        require("config")
        require("keys")
      '';
      inherit aliases;
      desktopEntry = true;
      inherit neovim extraBinPath appName;
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
        opt = [
          vimPlugins.nvim-navbuddy
          vimPlugins.bufferline-nvim
          vimPlugins.showkeys
          vimPlugins.markview-nvim
          vimPlugins.lsp-progress-nvim
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
          vimPlugins.codecompanion-nvim
        ];
      };
    };
  };
in {
  home = lib.mkIf enabled homeConfig;
  nixos = lib.mkIf enabled {};
  config = homeConfig;
}
