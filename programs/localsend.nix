{
  lib,
  enabled,
  ...
}: {
  home =
    lib.mkIf enabled {
    };
  nixos = lib.mkIf enabled {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
