{
  pkgs,
  user,
  host,
  ...
}: let
  imports = [
    ./desktop-hardware.nix
    ./cachix.nix
    ./steam.nix
    ./user-config.nix
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
  networking = {
    hostName = host;
    networkmanager.enable = true;
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
      windowManager.xmonad = {
        enable = false;
        enableContribAndExtras = false;
        extraPackages = haskellPackages:
          with haskellPackages; [
            #X11
            #containers_0_6_6
            #directory_1_3_8_0
            #filepath_1_4_100_0
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
}
