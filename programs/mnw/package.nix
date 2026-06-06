{
  pkgs,
  ...
}: let
  vimPlugins = pkgs.vimPlugins // import ../../lib/vim-plugins.nix {
    inherit pkgs;
    vimPlugins = pkgs.vimPlugins;
  };
in {
  neovim = pkgs.neovim-unwrapped;
  inherit vimPlugins;
  extraBinPath = [
    pkgs.imagemagick
    pkgs.ffmpeg
    pkgs.ghostscript
  ];
  statusline = pkgs.vimUtils.buildVimPlugin {
    name = "heirline";
    src = ./lua/plugins/statusline;
    doCheck = false;
  };
}
