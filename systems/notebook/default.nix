{
  config,
  lib,
  ...
}: let
  imports = [
    ./hardware.nix
    ./disko.nix
    ./boot.nix
  ];
in {
  inherit imports;
  programs = {
    nix-ld.enable = true;
  };
  environment.systemPackages = [
    config.boot.kernelPackages.nvidiaPackages.stable
  ];
  virtualisation.docker.enable = true;
  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "zstd";
  };
  services = {
    envfs.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      wireplumber.enable = true;
      pulse.enable = true;
    };

    auto-cpufreq.enable = true;
    fstrim.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = lib.mkForce false;
    tlp.enable = true;
    tlp.settings = {
      # Disable conflicting power-profiles-daemon
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      INTEL_GPU_MIN_FREQ_ON_AC = 300;
      INTEL_GPU_MAX_FREQ_ON_AC = 1100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 800;
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ENABLE = [
        "00:02.0"
        "01:00.0"
      ];
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";
      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      USB_AUTOSUSPEND = 1;
    };
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Native Wayland for Electron apps
    COSMIC_DATA_CONTROL_ENABLED = "1"; # Allows clipboard managers to work
    WLR_NO_HARDWARE_CURSORS = "1"; # Fixes invisible cursor on NVIDIA
  };
  security.rtkit.enable = true;
}
