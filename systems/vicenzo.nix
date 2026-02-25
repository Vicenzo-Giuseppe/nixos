{
  pkgs,
  user,
  config,
  host,
  ...
}: let
  fullname = "Vicenzo Giuseppe Furno Baptista";
  nixpkgs = "nixpkgs=/etc/nixpkgs";
  groups = [
    "ssh"
    "aria2"
    "input"
    "uinput"
    "wheel"
    "networkmanager"
    "docker"
    "video"
    "render"
  ];
  en_US = "en_US.UTF-8";
  pt_BR = "pt_BR.UTF-8";
  timezone = "America/Sao_Paulo";
in {
  networking = {
    hostName = host;
    networkmanager.enable = true;
  };
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
  environment.etc.nixpkgs.source = pkgs.path;
  nix = {
    nixPath = [
      nixpkgs
    ];
  };
  users.users."${user}" = {
    isNormalUser = true;
    description = fullname;
    #hashedPasswordFile = config.sops.secrets.user_password.path;
    extraGroups = groups;
    shell = pkgs.zsh;
    password = "[";
  };
  fonts.packages = with pkgs.nerd-fonts; [
    fira-code
    droid-sans-mono
  ];
  system.stateVersion = "25.11";
}
