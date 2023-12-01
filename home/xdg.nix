{...}: let
in {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "\$HOME/Desktop";
      createDirectories = false;
      extraConfig = {_ = "\$HOME/_";};
    };
  };
}
