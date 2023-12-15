{
  nix = {
    settings = {
      substituters = [
        "https://holochain-ci.cachix.org"
      ];
      trusted-public-keys = [
        "holochain-ci.cachix.org-1:5IUSkZc0aoRS53rfkvH9Kid40NpyjwCMCzwRTXy+QN8="
      ];
    };
  };
}
