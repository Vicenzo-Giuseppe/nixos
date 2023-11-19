{
  pkgs,
  user,
  ...
}: let
  config = pkgs.fetchgit {
    url = "https://github.com/abzcoding/lvim";
    rev = "f5c27e93d2c9f972182f87d4f3ea6d2f94d95384";
    sha256 = "sha256-XQkMuE2uXT0/Vwgmemleopm4U5qAbvzo/Tow+HK1SEQ=";
  };
  lunarvim = pkgs.fetchgit {
    url = "https://github.com/LunarVim/LunarVim";
    rev = "9dc549a4edd4b79f7f3bcad0e386e490a6a2b952";
    sha256 = "sha256-KhHy8np6iCZhIOOGVFVy9eLkN/72KwPwjPBDKpkfnHI=";
  };
  lvim = "$HOME/.local/bin/lvim";
in {
  home = {
    file = {
      lvim = {
        source = lunarvim;
        target = ".local/share/lunarvim/lvim";
      };
      lvimconfig = {
        source = config;
        target = ".config/lvim";
      };
      lvim_bin = {
        text = ''
          #!/usr/bin/env bash
          export LUNARVIM_RUNTIME_DIR=/home/${user}/.local/share/lunarvim
          export LUNARVIM_CONFIG_DIR=/home/${user}/.config/lvim
          export LUNARVIM_CACHE_DIR=/home/${user}/.cache/lvim
          export LUNARVIM_BASE_DIR=/home/${user}/.local/share/lunarvim/lvim
          exec -a lvim ${pkgs.neovim}/bin/nvim -u "$LUNARVIM_BASE_DIR/init.lua" "$@"
        '';
        target = ".local/bin/lvim";
        executable = true;
      };
    };
   # packages = with pkgs; [tree-sitter fd stylua shellcheck deadnix luajitPackages.luacheck alejandra statix shfmt];
    packages = with pkgs; [cargo gnumake python311Packages.pip nodejs python3 nodePackages_latest.pnpm ];
  };
  programs.zsh.shellGlobalAliases = {inherit lvim;};
}
