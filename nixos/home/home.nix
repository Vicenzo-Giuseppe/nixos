{user, ...}: {
  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "23.05";
  };
}
