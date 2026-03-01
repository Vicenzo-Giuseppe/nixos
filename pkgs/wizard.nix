{
  buildGoModule,
  lib,
  ...
}:
buildGoModule {
  pname = "wizard";
  version = "0.1.0";
  src = ./wizard;
  vendorHash = "sha256-zhCIQJLvytzuhtZ8Vc0ct0zOW9/LljUcLs7k5zVlHvg=";
  meta = with lib; {
    description = "Wizard Guide for Setup my NixOS";
    mainProgram = "wizard";
    homepage = "https://github.com/Vicenzo-Giuseppe/nixos";
    maintainers = with maintainers; [Vicenzo-Giuseppe];
  };
}
