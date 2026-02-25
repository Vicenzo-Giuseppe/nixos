{
  pkgs,
  lib,
  enabled,
  ...
}: let
in {
  home =
    lib.mkIf enabled {
    };
  nixos = lib.mkIf enabled {
    security.wrappers.btop = {
      owner = "root";
      group = "root";
      capabilities = "cap_perfmon,cap_sys_admin,cap_net_raw+ep";
      source = "${pkgs.btop.override {cudaSupport = true;}}/bin/btop";
    };
  };
}
