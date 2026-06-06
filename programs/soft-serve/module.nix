{
  lib,
  pkgs,
  user,
  packageConfig,
  displayName ? "Vault7",
  sshHost ? "localhost",
  sshPort ? 23231,
  sshUser ? "admin",
  publicHost ? host,
  httpPort ? 23232,
  statsPort ? 23233,
  restrictSoftServeToLan ? false,
  lanCidrs ? [
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ],
  localSoftServeUser ? user,
  enabled,
  ...
}: let
  inherit (packageConfig) runtimeInputs;
  softServeName = displayName;
  adminUser = sshUser;
  adminKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4ufgdzMLLhEEVXl6ZpfejX5zCR0uUb64CySve34e9v";
  githubUser = user;
  githubRepo = "nixos";
  githubRemote = "git@github.com:${githubUser}/${githubRepo}.git";
  githubDeployKeyPath = "/var/lib/soft-serve/ssh/github_deploy";
  gitHooksPath = "/var/lib/soft-serve/git-hooks";
  gitConfigPath = "/var/lib/soft-serve/gitconfig";
  mirrorHookPath = "${gitHooksPath}/post-receive.mirror";
  localSoftServeKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEH4DiQuvyxkaY88E2WxNGBMYi9F6tKv2SrQ8qo29I61";
in {
  home = lib.mkIf enabled {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."${softServeName}" = {
        hostname = sshHost;
        port = sshPort;
        user = adminUser;
        identityFile = "/home/${user}/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };
  nixos = lib.mkIf enabled {
    services.soft-serve = {
      enable = true;
      settings = {
        name = softServeName;
        log_format = "text";
        ssh = {
          listen_addr = ":${toString sshPort}";
          public_url = "ssh://${publicHost}:${toString sshPort}";
          max_timeout = 30;
          idle_timeout = 120;
        };
        http = {
          listen_addr = ":${toString httpPort}";
          public_url = "http://${publicHost}:${toString httpPort}";
        };
        git.enabled = false;
        stats = {
          enabled = true;
          listen_addr = "127.0.0.1:${toString statsPort}";
        };
        initial_admin_keys = [adminKey];
      };
    };

    systemd.services.soft-serve = {
      environment = {
        GIT_CONFIG_GLOBAL = gitConfigPath;
        SOFT_SERVE_MIRROR_HOOK = mirrorHookPath;
        SOFT_SERVE_MIRROR_REPO = githubRepo;
        SOFT_SERVE_MIRROR_REMOTE = githubRemote;
        SOFT_SERVE_MIRROR_KEY = githubDeployKeyPath;
        SOFT_SERVE_MIRROR_PUSH_OPTION = "git=true";
        SOFT_SERVE_MIRROR_TAG = "publish";
        SOFT_SERVE_MIRROR_SSH_OPTS = "-o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new";
        SOFT_SERVE_GIT_BIN = "${pkgs.git}/bin/git";
        SOFT_SERVE_SSH_BIN = "${pkgs.openssh}/bin/ssh";
      };
      serviceConfig = {
        StateDirectory = "soft-serve";
        ReadWritePaths = ["/var/lib/soft-serve"];
        NoNewPrivileges = true;
      };
    };

    # systemd.services.soft-serve.preStart = ''
    #   ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/soft-serve/ssh ${gitHooksPath} /var/lib/soft-serve/hooks
    #
    #   cat > ${gitConfigPath} <<'EOF'
    #   [core]
    #     hooksPath = ${gitHooksPath}
    #   [receive]
    #     advertisePushOptions = true
    #   EOF
    #   ${pkgs.coreutils}/bin/chmod 0644 ${gitConfigPath}
    #
    #   if [ ! -f "${githubDeployKeyPath}" ]; then
    #     ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -a 64 -f "${githubDeployKeyPath}" -N "" -C "vault8->github"
    #   fi
    #
    #   ${pkgs.coreutils}/bin/install -m 0755 ${./soft-serve-hook-wrapper.sh} ${gitHooksPath}/pre-receive
    #   ${pkgs.coreutils}/bin/install -m 0755 ${./soft-serve-hook-wrapper.sh} ${gitHooksPath}/update
    #   ${pkgs.coreutils}/bin/install -m 0755 ${./soft-serve-hook-wrapper.sh} ${gitHooksPath}/post-update
    #   ${pkgs.coreutils}/bin/install -m 0755 ${./soft-serve-hook-wrapper.sh} ${gitHooksPath}/post-receive
    #   ${pkgs.coreutils}/bin/install -m 0755 ${./soft-serve-github-mirror.sh} ${mirrorHookPath}
    #
    # '';
    #
    networking.firewall = {
      allowedTCPPorts = [
        sshPort
        httpPort
      ];
      extraCommands = lib.mkIf restrictSoftServeToLan ''
        ${lib.concatMapStringsSep "\n" (cidr: ''
            iptables -I INPUT -p tcp --dport ${toString sshPort} -s ${cidr} -j ACCEPT
            iptables -I INPUT -p tcp --dport ${toString httpPort} -s ${cidr} -j ACCEPT
          '')
          lanCidrs}
        iptables -A INPUT -p tcp --dport ${toString sshPort} -j DROP
        iptables -A INPUT -p tcp --dport ${toString httpPort} -j DROP
      '';
      extraStopCommands = lib.mkIf restrictSoftServeToLan ''
        ${lib.concatMapStringsSep "\n" (cidr: ''
            iptables -D INPUT -p tcp --dport ${toString sshPort} -s ${cidr} -j ACCEPT 2>/dev/null || true
            iptables -D INPUT -p tcp --dport ${toString httpPort} -s ${cidr} -j ACCEPT 2>/dev/null || true
          '')
          lanCidrs}
        iptables -D INPUT -p tcp --dport ${toString sshPort} -j DROP 2>/dev/null || true
        iptables -D INPUT -p tcp --dport ${toString httpPort} -j DROP 2>/dev/null || true
      '';
    };

    systemd.services.soft-serve-bootstrap = {
      description = "Bootstrap Soft Serve local user";
      after = [
        "soft-serve.service"
        "network-online.target"
      ];
      requires = ["soft-serve.service"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      path = [
        pkgs.coreutils
        pkgs.python3
      ] ++ runtimeInputs;
      environment = {
        SOFT_SERVE_DB_PATH = "/var/lib/soft-serve/soft-serve.db";
        SOFT_SERVE_ADMIN_USER = adminUser;
        SOFT_SERVE_ADMIN_KEY = adminKey;
        SOFT_SERVE_LOCAL_USER = localSoftServeUser;
        SOFT_SERVE_LOCAL_KEY = localSoftServeKey;
      };
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = ["/var/lib/soft-serve"];
      };
      script = ''
        set -euo pipefail

        db_path="$SOFT_SERVE_DB_PATH"

        for _ in $(seq 1 30); do
          if [ -f "$db_path" ]; then
            break
          fi
          sleep 1
        done

        if [ ! -f "$db_path" ]; then
          echo "soft-serve db not found; skipping bootstrap"
          exit 0
        fi

        if ! python3 ${./soft-serve-bootstrap.py}; then
          echo "soft-serve bootstrap failed; skipping"
        fi
      '';
    };
  };
}
