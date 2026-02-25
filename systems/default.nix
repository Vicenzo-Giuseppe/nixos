{
  host,
  system,
  user,
  Config,
  ...
}: let
in {
  ${host} = {
    modules = [
      ./${user}.nix
      ./${host}
      ../lib/nixos.nix
    ];
    extraArgs = {
      inherit
        system
        user
        host
        Config
        ;
    };
  };
}
