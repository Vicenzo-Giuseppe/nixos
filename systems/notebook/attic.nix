{
  lib,
  pkgs,
  host,
  ...
}: let
  atticPort = 8081;
  cacheName = host;
  atticStateDir = "/var/lib/atticd";
  atticEnvFile = "${atticStateDir}/atticd.env";
  atticBootstrapDir = "/var/lib/attic-bootstrap";
  atticPublicDir = "/var/lib/attic";
  atticServer = "local";
  atticLocalEndpoint = "http://127.0.0.1:${toString atticPort}/";
  atticLocalCacheEndpoint = "${atticLocalEndpoint}${cacheName}";
  atticPublicKey = "notebook:kQR/CtFur54BgcXosKuHw17fQh8FfbLdBXLXcLWJ+J4=";
  adminTokenFile = "${atticBootstrapDir}/${cacheName}.admin.token";
  pushTokenFile = "${atticBootstrapDir}/${cacheName}.push.token";
  publicKeyFile = "${atticPublicDir}/${cacheName}.public-key";
  cacheInfoFile = "${atticPublicDir}/${cacheName}.cache-info";
  watchStoreJobs = "12";

  atticPushPath = pkgs.writeShellScriptBin "attic-push-path" ''
    set -euo pipefail

    if [ "$#" -lt 1 ]; then
      echo "usage: attic-push-path /nix/store/<path> [...]" >&2
      exit 1
    fi

    token="$(${pkgs.coreutils}/bin/env -i PATH=${pkgs.coreutils}/bin:/run/current-system/sw/bin HOME=/tmp \
      /run/current-system/sw/bin/atticd-atticadm make-token \
        --sub attic-push-path \
        --validity '1 hour' \
        --pull ${cacheName} \
        --push ${cacheName})"

    workdir="$(${pkgs.coreutils}/bin/mktemp -d)"
    trap 'rm -rf "$workdir"' EXIT

    export HOME="$workdir"
    export XDG_CONFIG_HOME="$workdir/.config"

    ${pkgs.attic-client}/bin/attic login ${atticServer} ${atticLocalEndpoint} "$token" >/dev/null
    exec ${pkgs.attic-client}/bin/attic push ${atticServer}:${cacheName} "$@"
  '';

  atticInfo = pkgs.writeShellScriptBin "attic-notebook-info" ''
    set -euo pipefail

    echo "Attic cache: ${cacheName}"
    echo "API endpoint: ${atticLocalEndpoint}"
    echo "Binary cache: ${atticLocalCacheEndpoint}"
    echo "Storage backend: local (${atticStateDir}/storage)"

    if [ -f ${publicKeyFile} ]; then
      echo "Public key: $(cat ${publicKeyFile})"
    else
      echo "Public key: not bootstrapped yet"
    fi

    echo ""
    echo "Bootstrap files:"
    echo "  admin token: ${adminTokenFile}"
    echo "  push token: ${pushTokenFile}"
    echo "  public key: ${publicKeyFile}"
    echo "  cache info: ${cacheInfoFile}"
    echo ""
    echo "Local uploader: attic-watch-store.service"
  '';
in {
  services.atticd = {
    enable = true;
    environmentFile = atticEnvFile;
    settings = {
      listen = "127.0.0.1:${toString atticPort}";
      api-endpoint = atticLocalEndpoint;
      database.url = "sqlite://${atticStateDir}/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "${atticStateDir}/storage";
      };
    };
  };

  environment.systemPackages = [
    pkgs.attic-client
    atticInfo
    atticPushPath
  ];

  nix.settings = {
    extra-substituters = [atticLocalCacheEndpoint];
    extra-trusted-public-keys = [atticPublicKey];
  };

  systemd.tmpfiles.rules = [
    "d ${atticBootstrapDir} 0700 root root -"
    "d ${atticPublicDir} 0755 root root -"
  ];

  systemd.services.atticd-credentials = {
    description = "Generate Attic server credentials";
    before = ["atticd.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.coreutils
      pkgs.openssl
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      install -d -m 0700 ${atticStateDir} ${atticBootstrapDir}

      if [ ! -f ${atticEnvFile} ]; then
        secret="$(${lib.getExe pkgs.openssl} genrsa -traditional 4096 | ${pkgs.coreutils}/bin/base64 -w0)"
        printf 'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="%s"\n' "$secret" > ${atticEnvFile}
        chmod 0600 ${atticEnvFile}
      fi
    '';
  };

  systemd.services.atticd-scrub-legacy-refs = {
    description = "Remove stale non-local Attic chunk references";
    before = ["atticd.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.coreutils
      pkgs.sqlite
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    script = ''
            set -euo pipefail

            db=/var/lib/atticd/server.db
            if [ ! -f "$db" ]; then
              exit 0
            fi

            stale_count="$(${pkgs.sqlite}/bin/sqlite3 "$db" "SELECT COUNT(*) FROM chunk WHERE remote_file_id NOT LIKE 'local:%';")"
            if [ "$stale_count" = "0" ]; then
              exit 0
            fi

            ${pkgs.sqlite}/bin/sqlite3 "$db" <<'SQL'
            BEGIN IMMEDIATE;
            CREATE TEMP TABLE stale_nar(id INTEGER PRIMARY KEY);
            INSERT INTO stale_nar
              SELECT DISTINCT chunkref.nar_id
              FROM chunk
              JOIN chunkref ON chunkref.chunk_id = chunk.id
              WHERE chunk.remote_file_id NOT LIKE 'local:%';

            DELETE FROM object
              WHERE nar_id IN (SELECT id FROM stale_nar);

            DELETE FROM chunkref
              WHERE nar_id IN (SELECT id FROM stale_nar);

            DELETE FROM nar
              WHERE id IN (SELECT id FROM stale_nar);

            DELETE FROM chunk
              WHERE remote_file_id NOT LIKE 'local:%';
            COMMIT;
            VACUUM;
      SQL
    '';
  };

  systemd.services.atticd = {
    requires = [
      "atticd-credentials.service"
      "atticd-scrub-legacy-refs.service"
    ];
    after = [
      "atticd-credentials.service"
      "atticd-scrub-legacy-refs.service"
    ];
  };

  systemd.services.atticd-bootstrap = {
    description = "Bootstrap notebook Attic cache";
    after = ["atticd.service"];
    requires = ["atticd.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.attic-client
      pkgs.coreutils
      pkgs.gnused
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
    script = ''
      set -euo pipefail

      workdir="$(mktemp -d)"
      trap 'rm -rf "$workdir"' EXIT

      export HOME="$workdir"
      export XDG_CONFIG_HOME="$workdir/.config"

      /run/current-system/sw/bin/atticd-atticadm \
        make-token \
        --sub "${cacheName}-admin" \
        --validity 5y \
        --create-cache '*' \
        --pull '*' \
        --push '*' \
        --delete '*' \
        --configure-cache '*' > ${adminTokenFile}
      chmod 0600 ${adminTokenFile}

      attic login ${atticServer} ${atticLocalEndpoint} "$(cat ${adminTokenFile})"

      if ! attic cache info ${atticServer}:${cacheName} >/dev/null 2>&1; then
        attic cache create --public ${atticServer}:${cacheName}
      fi

      /run/current-system/sw/bin/atticd-atticadm \
        make-token \
        --sub "${cacheName}-uploader" \
        --validity 5y \
        --pull "${cacheName}" \
        --push "${cacheName}" > ${pushTokenFile}
      chmod 0600 ${pushTokenFile}

      attic cache info ${atticServer}:${cacheName} > ${cacheInfoFile} 2>&1
      chmod 0644 ${cacheInfoFile}
      sed -n 's/^[[:space:]]*Public Key:[[:space:]]*//p' ${cacheInfoFile} > ${publicKeyFile}
      chmod 0644 ${publicKeyFile}
    '';
  };

  systemd.services.attic-watch-store = {
    description = "Watch the local Nix store and upload new paths to Attic";
    after = ["atticd-bootstrap.service"];
    requires = ["atticd-bootstrap.service"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = pushTokenFile;
    };
    path = [
      pkgs.attic-client
      pkgs.coreutils
    ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      Restart = "always";
      RestartSec = "10s";
      StateDirectory = "attic-watch-store";
    };
    script = ''
      set -euo pipefail

      export HOME="$STATE_DIRECTORY"
      export XDG_CONFIG_HOME="$STATE_DIRECTORY/.config"
      install -d -m 0700 "$XDG_CONFIG_HOME"

      attic login ${atticServer} ${atticLocalEndpoint} "$(cat ${pushTokenFile})" >/dev/null
      exec attic watch-store ${atticServer}:${cacheName} -j ${watchStoreJobs}
    '';
  };
}
