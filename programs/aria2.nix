{
  pkgs,
  lib,
  enabled,
  ...
}: let
  aria2Port = 6800;
  webPort = 8080;
  # Trackers atualizados
  trackers = "udp://tracker.opentrackr.org:1337/announce,http://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://tracker.openbittorrent.com:6969/announce,http://tracker.openbittorrent.com:80/announce,udp://open.stealth.si:80/announce,udp://tracker.torrent.eu.org:451/announce,udp://exodus.desync.com:6969/announce,udp://explodie.org:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://movies.zsw.ca:6969/announce,udp://uploads.gamecoast.net:6969/announce,udp://tracker1.bt.moack.co.kr:80/announce,udp://tracker.tiny-vps.com:6969/announce,udp://tracker.theoks.net:6969/announce,udp://tracker.therarbg.com:6969/announce,udp://tracker.t-rb.org:6969/announce,udp://tracker.qu.ax:6969/announce,udp://tracker.dler.org:6969/announce,udp://tracker.cyberia.is:6969/announce,udp://tracker.moeking.me:6969/announce,udp://tracker.bittor.pw:1337/announce,udp://bt.ktrackers.com:6666/announce,udp://opentracker.io:6969/announce,udp://opentor.org:2710/announce,udp://tracker.0x7c0.com:6969/announce,udp://tracker.edkj.club:6969/announce,udp://tracker.filemail.com:6969/announce,udp://tracker.fnix.net:6969/announce,udp://tracker.gbitt.info:80/announce,udp://tracker.ipv6tracker.ru:80/announce,udp://tracker.nartlof.com.br:6969/announce,udp://tracker.renfei.net:8080/announce,udp://tracker.skynetcloud.site:6969/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.srv00.com:6969/announce,udp://tracker.tamersunion.org:6969/announce,udp://tracker.yemekyedim.com:6969/announce,udp://tracker1.520.jp:6969/announce,udp://tracker2.dler.org:80/announce,udp://tracker3.itzmx.com:6961/announce,udp://trackers.mlsub.net:6969/announce,udp://wepzone.net:6969/announce,udp://www.torrent.eu.org:451/announce,http://1337.abcvg.info:80/announce,http://bt.okmp3.ru:2710/announce,http://bvarf.tracker.sh:2086/announce,http://nyaa.tracker.wf:7777/announce,http://open.acgnxtracker.com:80/announce,http://share.camoe.cn:8080/announce,http://t.nyaatracker.com:80/announce,http://torrentsmd.com:8080/announce,http://tracker.bt4g.com:2095/announce,http://tracker.electro-torrent.pl:80/announce,http://tracker.files.fm:6969/announce,http://tracker.gbitt.info:80/announce,http://tracker.renfei.net:8080/announce,http://tracker.tfile.co:80/announce,http://www.all4nothin.net:80/announce.php,https://1337.abcvg.info:443/announce,https://tr.burnabyhighstar.com:443/announce,https://tracker.cloudit.top:443/announce,https://tracker.gbitt.info:443/announce,https://tracker.kuroy.me:443/announce,https://tracker.lilithraws.cf:443/announce,https://tracker.lilithraws.org:443/announce,https://tracker.loligirl.cn:443/announce,https://tracker.tamersunion.org:443/announce,https://tracker.yemekyedim.com:443/announce,https://tracker1.520.jp:443/announce,https://trackers.mlsub.net:443/announce,https://www.peckservers.com:9443/announce,wss://tracker.openwebtorrent.com:443/announce";
in {
  nixos = lib.mkIf enabled {
    # ARIA2
    services.aria2 = {
      enable = true;
      rpcSecretFile = "/var/lib/aria2/secret";
      rpcListenPort = aria2Port;
      openPorts = true;
      settings = {
        rpc-listen-all = true;
        rpc-allow-origin-all = true;
        rpc-secure = false;
        dir = "/var/lib/aria2/Downloads";
        continue = true;
        file-allocation = "none";
        disk-cache = "512M";
        max-overall-download-limit = 0;
        max-overall-upload-limit = 0;
        max-download-limit = 0;
        max-upload-limit = 0;
        max-concurrent-downloads = 100;
        max-connection-per-server = 16;
        min-split-size = "1M";
        split = 128;
        bt-max-peers = 0;
        bt-request-peer-speed-limit = "100M";
        enable-dht = true;
        enable-dht6 = false;
        enable-peer-exchange = true;
        bt-enable-lpd = true;
        dht-entry-point = "dht.transmissionbt.com:6881";
        dht-entry-point6 = "dht.transmissionbt.com:6881";
        listen-port = [
          {
            from = 6881;
            to = 6999;
          }
        ];
        dht-listen-port = 6881;
        bt-tracker = trackers;
        bt-tracker-connect-timeout = 2;
        bt-tracker-timeout = 5;
        bt-tracker-interval = 0;
        bt-save-metadata = true;
        bt-load-saved-metadata = true;
        follow-torrent = "true";
        bt-metadata-only = false;
        bt-max-open-files = 5000;
        bt-prioritize-piece = "head=128M,tail=128M";
        bt-force-encryption = false;
        bt-min-crypto-level = "plain";
        bt-require-crypto = false;
        seed-ratio = 0;
        seed-time = 0;
        user-agent = "Transmission/3.00";
        peer-id-prefix = "-TR3000-";
        disable-ipv6 = true;
        dht-message-timeout = 3;
        enable-upnp = true;
        enable-nat-pmp = true;
        check-integrity = true;
        real-time-chunk-checksum = true;
        auto-save-interval = 30;
        connect-timeout = 10;
        timeout = 30;
        max-tries = 5;
        retry-wait = 5;
      };
    };

    # CADDY para AriaNg
    services.caddy = {
      enable = true;
      virtualHosts.":${toString webPort}" = {
        extraConfig = ''
          file_server {
            root ${pkgs.ariang}/share/ariang
          }
          reverse_proxy /jsonrpc localhost:${toString aria2Port}
        '';
      };
    };

    # Firewall
    networking.firewall = {
      allowedTCPPorts = [
        webPort
      ];
    };
    # Permissões
    users.users.vicenzo.extraGroups = ["aria2"];
    systemd.tmpfiles.rules = [
      "d /var/lib/aria2/Downloads 0775 aria2 aria2 -"
    ];
  };
  home = lib.mkIf enabled {
    home.packages = with pkgs; [
      aria2
      ariang
    ];
  };
}
