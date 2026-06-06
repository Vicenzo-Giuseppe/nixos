{
  pkgs,
  config,
  lib,
  ...
}: let
  # ds4drv 0.5.1 still references evdev's removed `InputDevice.fn` attribute.
  # Patch to `path` so the DualShock -> XInput bridge works on current nixpkgs.
  ds4drvPatched = pkgs.python3Packages.ds4drv.overridePythonAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace ds4drv/actions/input.py \
          --replace-fail "joystick.device.device.fn" "joystick.device.device.path"
      '';
  });
in {
  nix.settings = {
    # Full auto parallelism is too aggressive for 15 GiB RAM during large Rust builds.
    max-jobs = lib.mkForce 4;
    cores = lib.mkForce 4;
  };

  environment.variables = {
    # Keep cargo from spawning enough rustc jobs to stall the whole machine.
    CARGO_BUILD_JOBS = "4";
  };

  environment.systemPackages = [
    config.boot.kernelPackages.nvidiaPackages.stable
    pkgs.v4l-utils # Webcam diagnostics (v4l2-ctl, qv4l2)
    ds4drvPatched # DualShock 4 to virtual Xbox 360 (XInput-like) bridge
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
      powerManagement.enable = true;
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
      "snd_hda_intel.dmic_detect=1" # NotebookMicrophone
      "snd_hda_intel.model=lenovo-headset-mode" # NotebookMicrophone
    ];
  };
  services = {
    envfs.enable = true; # BinarySupport
    fwupd.enable = true; # Firmware updates
    thermald.enable = true; # ThermalManagent ( ex fan speed % x Temperature)
  };
  # Export a virtual Xbox 360 controller from a DualShock 4 for games that
  # only detect XInput devices.
  systemd.services.ds4-xinput-bridge = {
    description = "DualShock 4 to XInput bridge";
    wantedBy = ["multi-user.target"];
    after = ["bluetooth.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 2;
      ExecStart = "${ds4drvPatched}/bin/ds4drv --hidraw --emulate-xpad --ignored-buttons PS";
    };
  };
  programs = {
    nix-ld.enable = true; # BinarySupport
  };
  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "zstd";
    memoryPercent = 100;
  };
  # extraModprobeConfig = ''
  #   options legion_laptop force=1
  # '';
  # extraModulePackages = [ config.boot.kernelPackages.lenovo-legion-module ];
}
