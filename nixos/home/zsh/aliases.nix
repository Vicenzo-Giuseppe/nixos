{
  host,
  user,
  ...
}: let
  eza = "eza --color=always --icons --group-directories-first -F ";
  overview = "--no-time --no-user --no-filesize --no-permissions";
in {
  programs.zsh.shellAliases = {
    c = "clear";
    # exa listFiles
    x = "${eza} -T "; # PathTreeFormat
    xs = "${eza} -l -T ${overview}"; # AllTreeFormat
    xl = "${eza} -l ${overview}"; # listformat
    xx = "${eza} -a "; # AllFiles
    xll = "${eza} -al ${overview} "; # list format all
    "x." = "${eza} -a | egrep '^\.'"; # list archives with dot
    # corsair rgb control
    icue = "ckb-n ext &!";
    # modify defaults commands
    grep = "grep --color=auto";
    egrep = "egrep --color=auto";
    fgrep = "fgrep --color=auto";
    cp = "cp -rf -i";
    mv = "mv -i";
    rm = "rm -i -rf";
    # others
    #nixos-rebuild = "sudo nixos-rebuild --flake '/home/${user}/nixos#${host}'";
    nixos-rebuild = "sudo nixos-rebuild --flake ${builtins.toString ./.}${host}";
  };
}
