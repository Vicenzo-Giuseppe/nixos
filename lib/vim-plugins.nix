{
  pkgs,
  ...
}: let
  buildVimPlugin = pkgs.vimUtils.buildVimPlugin;
in {
  showkeys = buildVimPlugin {
    pname = "showkeys";
    version = "0-unstable-2025-05-24";
    src = pkgs.fetchFromGitHub {
      owner = "nvzone";
      repo = "showkeys";
      rev = "cb0a50296f11f1e585acffba8c253b9e8afc1f84";
      hash = "sha256-mn/SBtk9YbYZRTJZ054IVsSVOlrry5gsHOXQEnd3b7M=";
    };
  };

  markview-nvim = buildVimPlugin {
    pname = "markview.nvim";
    version = "28.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "OXY2DEV";
      repo = "markview.nvim";
      rev = "v28.2.0";
      hash = "sha256-5Oad1VPZqazGXyXDhsfxKMuKqgdaTr5e1IaZGgfdHWQ=";
    };
  };

  lsp-progress-nvim = buildVimPlugin {
    pname = "lsp-progress.nvim";
    version = "2.0.0-1-unstable-2025-03-11";
    src = pkgs.fetchFromGitHub {
      owner = "linrongbin16";
      repo = "lsp-progress.nvim";
      rev = "f6d5af10563b895ff846346f57cbd4451439f4c1";
      hash = "sha256-6qSh2tOoopTURzqNUBk2VDbSiz4ZlYRtO8hkg8OkPUs=";
    };
  };

  codecompanion-nvim = buildVimPlugin {
    pname = "codecompanion.nvim";
    version = "19.13.0";
    src = pkgs.fetchFromGitHub {
      owner = "olimorris";
      repo = "codecompanion.nvim";
      rev = "v19.13.0";
      hash = "sha256-9jSFvxX9m1+pFNY7YNRPz4Emm1HzNW/MjvR9BNDZpAo=";
    };
  };
}
