{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mangohud
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    package =
      pkgs.steam.override
      {
        extraLibraries = _: with pkgs; [latencyflex];
      };
  };
  hardware = {
    steam-hardware.enable = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        reaper_freq = 5;
        defaultgov = "performance";
        softrealtime = "auto";
        renice = 0;
        ioprio = 0;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
        amd_performance_level = "high";
      };
    };
  };
}
