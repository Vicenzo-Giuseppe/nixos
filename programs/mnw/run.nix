{
  inputs,
  pkgs,
  rootConfig,
  module,
  name ? "mnw",
  executable ? "zv",
  ...
}: let
  home = inputs.home.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      inputs.mnw.homeManagerModules.default
      (module.config or module.home or module)
      {
        home = {
          username = rootConfig.user;
          homeDirectory = "/home/${rootConfig.user}";
          stateVersion = "24.11";
        };
      }
    ];
  };
  package = home.config.programs.mnw.finalPackage or home.config.programs.mnw.package;
in
  pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [package];
    text = ''
      exec ${package}/bin/${executable} "$@"
    '';
  }
