{
  host,
  system,
  user,
  Config,
  ...
}: {
  ${host} = {
    modules = [
      ./${user}.nix
      ./${host}
      ./boot.nix
      ./audio.nix
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
