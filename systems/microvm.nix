{inputs, ...}: let
  inherit (inputs) home;
in {
  # DON'T use microvm.vms here - this is a standalone VM!

  system.stateVersion = "24.11";
  networking.hostName = "myvm";

  # User setup
  users.users.vmuser = {
    isNormalUser = true;
    home = "/home/vmuser";
  };

  # Home Manager inside the VM
  imports = [
    home.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.vmuser = {pkgs, ...}: {
    home.stateVersion = "24.11";
    home.packages = with pkgs; [
      vim
      git
    ];
    programs.bash.enable = true;
    programs.home-manager.enable = true;
  };

  # ============================================
  # STANDALONE MICROVM OPTIONS (NOT microvm.vms!)
  # ============================================
  microvm = {
    hypervisor = "qemu";
    graphics = {
      enable = true;
      backend = "gtk"; # ou "sdl"
    };

    # Agora forwardPorts funciona!
    interfaces = [
      {
        type = "user";
        id = "eth0";
        mac = "02:00:00:01:02:03"; # ✅ MAC address obrigatório!
      }
    ];

    forwardPorts = [
      {
        from = "host";
        host.port = 5900;
        guest.port = 5900;
      } # SPICE
    ];
  };
  # Drivers de vídeo para SPICE
  services.xserver = {
    enable = true;
    videoDrivers = ["qxl"]; # Driver recomendado para SPICE
  };
  services.spice-vdagentd.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
}
