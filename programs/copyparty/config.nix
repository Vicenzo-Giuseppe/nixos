{
  host,
  user,
  ...
}: let
  isPhone = host == "phone";
  homeDir =
    if isPhone
    then "/data/data/com.termux.nix/files/home"
    else "/home/${user}";
in {
  output = {
    name = "copyparty";
    executable = "copyparty";
    port = 3923;
    bind = "0.0.0.0";
    defaultPhoneUrl = "http://phone:3923";
    serverName = if isPhone then "poco-x6-pro" else "phone-videos";
    sharePath = "${homeDir}/storage/shared/Download/zus";
    configHome = "${homeDir}/.config/copyparty";
    dataHome = "${homeDir}/.local/share/copyparty";
  };
}
