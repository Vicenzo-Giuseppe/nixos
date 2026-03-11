{
  lib,
  user,
  enabled,
  ...
}: {
  home = lib.mkIf enabled { };
  nixos = lib.mkIf enabled {
    services.spacebot = {
      enable = true;
      pathUser = user;
      variant = "full";
    };
  };
}
