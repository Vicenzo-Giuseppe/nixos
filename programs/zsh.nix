{
  pkgs,
  lib,
  enabled,
  host,
  ...
}: let
  #inherit (inputs) systemd;
  #system = "${systemd.packages.x86_64-linux.default}/bin/systemd-manager-tui";
  sensors = "${lib.getExe pkgs.hwinfo-tui}";
  weather = "${lib.getExe pkgs.stormy}";
  x = "eza --color=always --icons --group-directories-first -F ";
  overview = "--no-time --no-user --no-filesize --no-permissions";
in {
  home = lib.mkIf enabled {
    home = {
      packages = with pkgs; [
        eza
        bat
      ];
    };
    programs.zsh = {
      enable = true;
      autocd = true;
      cdpath = map toString [/etc/nixos];
      #defaultKeymap = "vicmd";
      dirHashes = {
        down = "$HOME/Downloads";
      };
      plugins = [
        {
          name = "zsh-z";
          src = pkgs.fetchFromGitHub {
            owner = "agkozak";
            repo = "zsh-z";
            rev = "dc9e2bc0cdbaa0a507371c248d3dcc9f58db8726";
            sha256 = "sha256-T0iZK9Tb7ExJaZ6e2UmwecnKHMQilwAPkyAa/uhqrw0=";
          };
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "a411ef3e0992d4839f0732ebeb9823024afaaaa8";
            sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "1386f1213eb0b0589d73cd3cf7c56e6a972a9bfd";
            sha256 = "sha256-iKx7lsQCoSAbpANYFkNVCZlTFdwOEI34rx/h1rnraSg=";
          };
        }
        {
          name = "zsh-autopair";
          src = pkgs.fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "396c38a7468458ba29011f2ad4112e4fd35f78e6";
            sha256 = "sha256-PXHxPxFeoYXYMOC29YQKDdMnqTO0toyA7eJTSCV6PGE=";
          };
        }
        {
          name = "asdf";
          src = pkgs.fetchFromGitHub {
            owner = "asdf-vm";
            repo = "asdf";
            rev = "816195d615427b033a7426a4fb4d7fac4cf2d791";
            sha256 = "sha256-9U8B6KRn27RrMqWXAUTTy+hrOgMv5Ii4YGsOZeX5Bl0=";
          };
        }
      ];

      shellAliases = {
        inherit x sensors weather;
        nvim = "${pkgs.neovim}/bin/nvim";
        c = "clear";
        cat = "bat";
        mk = "mkdir";
        search = "batgrep ";
        tasks = "yatto";
        #
        #zvd = "${lib.getExe config.programs.mnw.finalPackage.devMode}";

        # exa listFiles
        xs = "${x} -l -T ${overview}"; # AllTreeFormat
        xl = "${x} -l ${overview}"; # listformat
        xx = "${x} -a "; # AllFiles
        xll = "${x} -al ${overview} "; # list format all
        "x." = "${x} -a | egrep '^\.'"; # list archives with dot
        # modify defaults commands
        grep = "grep --color=auto";
        egrep = "egrep --color=auto";
        fgrep = "fgrep --color=auto";
        cp = "cp -rf -i";
        mv = "mv -i";
        rm = "rm -i -rf";
        # others
        nixos-rebuild = "sudo nixos-rebuild --flake .#${host} --impure";
        # wsl
        xp = "explorer.exe";
        np = "notepad.exe";
      };
    };
  };
  nixos = lib.mkIf enabled {
    programs.zsh.enable = true;
  };
}
