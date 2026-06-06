{inputs, names}: {
  defs = builtins.listToAttrs (builtins.map (name: {
    inherit name;
    value = import (inputs.self + "/systems/${name}/target.nix") {
      inherit inputs;
      cell = {};
    };
  }) names);
}
