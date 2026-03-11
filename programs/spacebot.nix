{
  lib,
  user,
  enabled,
  ...
}:
let
in
{
  home = lib.mkIf enabled {
    home.packages = [
    ];
  };
  nixos = lib.mkIf enabled {
    services.spacebot = {
      enable = true;
      pathUser = user;
      variant = "full";
    };
  };
}
