{inputs, ...}: let
  root = inputs.self;
  ctx = import (inputs.self + /lib/context.nix);
  system = ctx.system;
  user = ctx.user;
  inherit (inputs) home;
in {
  system.stateVersion = "24.11";
  networking.hostName = "${user}-vm";

  users.users."${user}-vm" = {
    isNormalUser = true;
    home = "/home/${user}-vm";
    hashedPassword = "!";
  };

  imports = [home.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${user}-vm" = {pkgs, ...}: {
      home.stateVersion = "24.11";
      home.packages = with pkgs; [vim git];
      programs.bash.enable = true;
      programs.home-manager.enable = true;
    };
  };

  microvm = {
    hypervisor = "qemu";
    graphics = {
      enable = true;
      backend = "gtk";
    };
    interfaces = [
      {
        type = "user";
        id = "eth0";
        mac = "02:00:00:01:02:03";
      }
    ];
    forwardPorts = [
      {
        from = "host";
        host.port = 5900;
        guest.port = 5900;
      }
    ];
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = ["qxl"];
      desktopManager.xfce.enable = true;
    };
    spice-vdagentd.enable = true;
  };
}
