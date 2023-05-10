{
  pkgs,
  haskellPackages,
  ...
}: let
  en_US = "en_US.UTF-8";
  pt_BR = "pt_BR.UTF-8";
  font = ["FiraCode" "DroidSansMono"];
  timezone = "America/Sao_Paulo";
  hostname = "nixos";
  user = "vicenzo";
  fullname = "Vicenzo Giuseppe Furno Baptista";
  groups = ["networkmanager" "wheel" "docker"];
  imports = [
    ./hardware.nix
    ./nix/config.nix
    ./cachix.nix
#    ./steam.nix
       "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
   (import ./disko-config.nix {
     disks = [ "/dev/sdb" ]; # replace this with your disk name i.e. /dev/nvme0n1
   })

  ];
in {
  inherit imports;
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  networking = {
    hostName = hostname;
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
      #videoDrivers = ["amdgpu"];
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
      #windowManager.xmonad = {
        #enable = true;
        #enableContribAndExtras = true;
        #extraPackages = haskellPackages:
          #with haskellPackages; [
            #      haskellPackages.X11
            #      haskellPackages.containers_0_6_6
            #      haskellPackages.directory_1_3_8_0
            #      haskellPackages.filepath_1_4_100_0
            # xmonad
            # xmonad-contrib
            # xmonad-extras
          #];
      #};
    #};
    printing.enable = true;
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
    pulseaudio.
    enable = false;
    bluetooth.enable = true;
    steam-hardware.enable = true;
    ckb-next.enable = true;
  };
  sound.enable = true;
  security.rtkit.enable = true;
  users.users."${user}" = {
    isNormalUser = true;
    description = fullname;
    extraGroups = groups;
    shell = pkgs.zsh;
    #    openssh.authorizedKeys.keyFiles = [
    #      ~/.config/ssh/key.pub
    #    ];
  };
  fonts.fonts = with pkgs; [
    (nerdfonts.override {fonts = font;})
  ];
  system.stateVersion = "22.11";
  programs.zsh.enable = true; # fix because already have it in home-manager
  programs.kdeconnect.enable = true;
}
