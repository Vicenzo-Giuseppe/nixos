{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = [
    config.boot.kernelPackages.nvidiaPackages.stable
  ];
  services.xserver.videoDrivers = ["nvidia"]; # NvidiaGraphicsSupport
  hardware = {
    enableAllFirmware = true; # Enable HardwareFirmwares - Hardware Support
    steam-hardware.enable = true; # Enable Gaming Support
    uinput.enable = true; # Controller, Devices Support
    firmware = [pkgs.sof-firmware]; # Sound Support
    bluetooth.enable = true; # Bluetooth
    graphics = {
      # NvidiaSupport
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      # proprietary driver (best for RTX 2050)
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = false;
      # PRIME hybrid graphics
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  boot = {
    blacklistedKernelModules = ["nouveau"];
    kernelModules = [
      "i915" # HibridGraphics (ex Intel Onboard GPU and NVIDIA gpu)
      "uinput" # Controller/Devices Support
      "intel_rapl_msr" # PowerManagement
      "intel_rapl_common" # PowerManagement
    ];
    kernelParams = [
      "nvidia-drm.modeset=1" # Graphics Support
      "nvidia.NVreg_DynamicPowerManagement=0x02" # PowerGPUInteligence
      "snd_hda_intel.model=alc257-laptop" # NotebookMicrophone
      "snd_hda_intel.dmic_detect=1" # NotebookMicrophone
      "snd_hda_intel.model=lenovo-headset-mode" # NotebookMicrophone
    ];
  };
  services = {
    envfs.enable = true; # BinarySupport
    thermald.enable = true; # ThermalManagent ( ex fan speed % x Temperature)
  };
  programs = {
    nix-ld.enable = true; # BinarySupport
  };
  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "zstd";
  };
  # extraModprobeConfig = ''
  #   options legion_laptop force=1
  # '';
  # extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
}
