{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl."kernel.dmesg_restrict" = 0;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
  security.rtkit.enable = true; # Real-TimePriority access for many programs
}
