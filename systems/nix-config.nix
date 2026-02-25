{
  nixpkgs,
  user,
  ...
}: let
  experimental-features = ["nix-command" "flakes"];
  trusted-users = [user "root"];
in {
  nixpkgs = "nixos-unstable";
  permittedInsecurePackages = [
    "python-2.7.18.6"
    "qtwebkit-5.212.0-alpha4"
    "electron-12.2.3"
  ];
  allowUnfree = true;
  allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) [
      "google-chrome"
      "warp-terminal"
      "steam-original"
      "crush"
      "steam-run"
      "steamcmd"
      "cuda-merged"
      "cuda_cupti"
      "claude-code"
      "minecraft-server"
      "cuda_nvdisasm"
      "cuda_nvml_dev"
      "cuda_gdb"
      "cuda_cuxxfilt"
      "cuda_nvprune"
      "cuda_profiler_api"
      "lunar-client"
      "cuda_nvrtc"
      "cuda_nvtx"
      "discord"
      "steam"
      "flagfox"
      "nvidia-settings"
      "cuda_nvrtc"
      "cuda_cudart"
      "libcublas"
      "cuda_cccl"
      "cuda_cuobjdump"
      "cuda_nvcc"
      "nvidia-x11"
      "spotify"
    ];
  nix.settings = {
    inherit trusted-users experimental-features;
    substitures = ["https://cache.nixos.org/"];
    trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
  };
}
