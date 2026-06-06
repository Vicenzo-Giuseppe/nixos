{user, ...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    trusted-users = [user];
    max-jobs = "auto";
    cores = 0;

    extra-substituters = [
      "https://hyprland.cachix.org/"
      "https://cache.numtide.com"
    ];

    trusted-substituters = [
      "https://hyprland.cachix.org"
      "https://cache.numtide.com"
    ];

    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
}
