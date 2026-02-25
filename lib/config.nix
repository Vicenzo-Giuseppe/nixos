# lib/config.nix - Config parser
{lib}: {
  # Load TOML config file
  load = path: builtins.fromTOML (builtins.readFile path);

  # Check if program is enabled
  isEnabled = cfg: name: let
    val = cfg.programs.${name} or false;
  in
    if lib.isBool val
    then val
    else val == "true";

  # Get all enabled programs
  enabled = cfg:
    builtins.attrNames (
      lib.filterAttrs (
        n: v:
          if lib.isBool v
          then v
          else v == "true"
      ) (cfg.programs or {})
    );

  # Simple extractors
  user = cfg: cfg.user   or "vicenzo";
  host = cfg: cfg.host   or "vicenzo";
  system = cfg: cfg.system or "x86_64-linux";
  pkgs = cfg: cfg.packages or [];
}
