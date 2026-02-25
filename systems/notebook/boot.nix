{
  pkgs,
  config,
  ...
}: {
  hardware = {
    enableAllFirmware = true;
    steam-hardware.enable = true;
    uinput.enable = true;
    firmware = [pkgs.sof-firmware];
    nvidia = {
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        sync.enable = false;
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:0:1:0";
      };
      nvidiaPersistenced = true;
      modesetting.enable = true;
      open = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth.enable = true;
  };
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "i915"
      "uinput"
      "intel_rapl_msr"
      "intel_rapl_common"
    ];
    kernelParams = [
      "i915.force_probe=*"
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_DynamicPowerManagement=0x02"
      "snd_hda_intel.model=alc257-laptop"
      "snd_hda_intel.dmic_detect=1"
      "snd_hda_intel.model=lenovo-headset-mode"
    ];
    extraModprobeConfig = ''
      options legion_laptop force=1
    '';
    extraModulePackages = [config.boot.kernelPackages.lenovo-legion-module];
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };
}
