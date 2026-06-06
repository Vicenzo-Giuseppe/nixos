{inputs, ...}: let
  ctx = import (inputs.self + /lib/context.nix);
  pkgs = import (inputs.self + /lib/nix-on-droid-pkgs.nix) {
    inherit inputs;
    system = ctx.phone.system;
  };
in {
  name = "phone";
  kind = "nix-on-droid";
  configuration = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    inherit pkgs;
    modules = [./config.nix];
    extraSpecialArgs = {
      inherit inputs;
      context = ctx.phone;
    };
    home-manager-path = inputs.home2405.outPath;
  };
}
