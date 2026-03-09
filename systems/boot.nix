{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
  security.rtkit.enable = true; # Real-TimePriority access for many programs
}
