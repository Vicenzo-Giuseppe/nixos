{
  pkgs,
  user,
  host,
  ...
}: let
  en_US = "en_US.UTF-8";
  pt_BR = "pt_BR.UTF-8";
  font = ["FiraCode" "DroidSansMono"];
  timezone = "America/Sao_Paulo";
  fullname = "Vicenzo Giuseppe Furno Baptista";
  nixpkgs = "nixpkgs=/etc/nixpkgs";
  groups = ["networkmanager" "wheel" "docker"];
  imports = [
    ./desktop-hardware.nix
    ./cachix.nix
    ./steam.nix
  ];
in {
  inherit imports;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };
  environment.etc.nixpkgs.source = pkgs.path;
  nix = {
    nixPath = [
      nixpkgs
    ];
  };
  networking = {
    hostName = host;
    networkmanager.enable = true;
  };
  virtualisation.docker.enable = true;
  time.timeZone = timezone;
  i18n = {
    defaultLocale = en_US;
    extraLocaleSettings = {
      LC_ADDRESS = pt_BR;
      LC_IDENTIFICATION = pt_BR;
      LC_MEASUREMENT = pt_BR;
      LC_MONETARY = pt_BR;
      LC_NAME = pt_BR;
      LC_NUMERIC = pt_BR;
      LC_PAPER = pt_BR;
      LC_TELEPHONE = pt_BR;
      LC_TIME = pt_BR;
    };
  };
  services = {
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = ["amdgpu"];
      displayManager = {
        autoLogin = {
          enable = true;
          inherit user;
        };
        sddm = {
          enable = true;
          theme = "catppuccin-mocha";
        };
      };
      desktopManager.plasma5.enable = true;
      xkbVariant = "";
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages:
          with haskellPackages; [
            #      haskellPackages.X11
            #      haskellPackages.containers_0_6_6
            #      haskellPackages.directory_1_3_8_0
            #      haskellPackages.filepath_1_4_100_0
            xmonad
            xmonad-contrib
            xmonad-extras
          ];
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [catppuccin-sddm];
  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
    steam-hardware.enable = true;
    ckb-next.enable = true;
  };
  sound.enable = true;
  users.users."${user}" = {
    isNormalUser = true;
    description = fullname;
    extraGroups = groups;
    shell = pkgs.zsh;
    initialHashedPassword = "]";
  };
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = font;})
  ];
  systemd.services.nixos-upgrade.path = [pkgs.git];
  system.stateVersion = "23.05";
  programs.zsh.enable = true; # fix because already have it in home-manager
}
