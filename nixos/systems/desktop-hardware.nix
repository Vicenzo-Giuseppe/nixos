{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  rtl88x2bu = [config.boot.kernelPackages.rtl88x2bu]; # NetworkAdapter
  UID1 = "e74a3e74-3602-433d-990c-757e2053c033";
  UID2 = "67AE-17E0";
  path = "/dev/disk/by-uuid/";
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
      kernelModules = ["amdgpu"];
    };
    kernelModules = ["kvm-amd" "i2c-dev" "i2c-piix4"];
    extraModulePackages = rtl88x2bu;
  };

  fileSystems."/" = {
    device = "${path}${UID1}";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "${path}${UID2}";
    fsType = "vfat";
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
