{inputs, ...}: let
in {
  programs.opencode.settings.permission = {
    edit = "ask";
    bash = {
      "nix*" = "allow";

      "ls*" = "allow";
      "pwd*" = "allow";
      "find*" = "allow";
      "grep*" = "allow";
      "rg*" = "allow";
      "cat*" = "allow";
      "head*" = "allow";
      "tail*" = "allow";
      "mkdir*" = "allow";
      "chmod*" = "allow";

      "rm*" = "ask";
      "mv*" = "ask";
      "cp*" = "ask";

      "curl*" = "ask";
      "wget*" = "ask";
      "ping*" = "ask";
      "ssh*" = "ask";
      "scp*" = "ask";
      "rsync*" = "ask";

      "sudo*" = "ask";
      "nixos-rebuild*" = "ask";

      "kill*" = "ask";
      "killall*" = "ask";
      "pkill*" = "ask";
    };
    read = "allow";
    list = "allow";
    glob = "allow";
    grep = "allow";
    webfetch = "allow";
    write = "ask";
    task = "allow";
    todowrite = "allow";
    todoread = "allow";
  };
}
