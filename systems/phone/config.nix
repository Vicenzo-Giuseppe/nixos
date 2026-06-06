{
  context,
  inputs,
  ...
}: {
  system.stateVersion = "24.05";

  android-integration = {
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
    xdg-open.enable = true;
  };

  environment.packages = [];

  user = {
    uid = context.uid;
    gid = context.gid;
  };

  home-manager.useUserPackages = true;

  home-manager.config = import ./home.nix {
    inherit context inputs;
  };
}
