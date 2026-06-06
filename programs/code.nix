{
  lib,
  pkgs,
  enabled,
  ...
}: let
  secretEnvRunner = pkgs.writeShellApplication {
    name = "code-secret-env";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      if [ "$#" -lt 3 ]; then
        echo "usage: code-secret-env <env-var> <secret-path> <command> [args...]" >&2
        exit 64
      fi

      var_name="$1"
      secret_path="$2"
      shift 2

      if [ -z "$var_name" ]; then
        echo "code-secret-env: env var name cannot be empty" >&2
        exit 64
      fi

      if [ ! -r "$secret_path" ]; then
        echo "code-secret-env: secret file not readable: $secret_path" >&2
        exit 66
      fi

      export "$var_name=$(tr -d '\n' < "$secret_path")"
      exec "$@"
    '';
  };

  waylandSessionRunner = pkgs.writeShellApplication {
    name = "code-wayland-session";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
    ];
    text = ''
            set -euo pipefail

            if [ "$#" -lt 1 ]; then
              echo "usage: code-wayland-session <command> [args...]" >&2
              exit 64
            fi

            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

            if [ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "$XDG_RUNTIME_DIR/bus" ]; then
              export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
            fi

            if systemd_env="$(${pkgs.systemd}/bin/systemctl --user show-environment 2>/dev/null)"; then
              while IFS= read -r line; do
                [ -n "$line" ] || continue
                key="''${line%%=*}"
                value="''${line#*=}"

                case "$key" in
                  DBUS_SESSION_BUS_ADDRESS|DISPLAY|HYPRLAND_INSTANCE_SIGNATURE|WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP|XDG_RUNTIME_DIR|XDG_SESSION_TYPE)
                    if [ -z "''${!key:-}" ]; then
                      export "$key=$value"
                    fi
                    ;;
                esac
              done <<EOF
      $systemd_env
      EOF
            fi

            if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
              for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
                [ -S "$socket" ] || continue
                export WAYLAND_DISPLAY="''${socket##*/}"
                break
              done
            fi

            if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "$XDG_RUNTIME_DIR/hypr" ]; then
              for session in "$XDG_RUNTIME_DIR"/hypr/*; do
                [ -d "$session" ] || continue
                export HYPRLAND_INSTANCE_SIGNATURE="''${session##*/}"
                break
              done
            fi

            export XDG_CURRENT_DESKTOP="''${XDG_CURRENT_DESKTOP:-Hyprland}"
            export XDG_SESSION_TYPE="''${XDG_SESSION_TYPE:-wayland}"

            exec "$@"
    '';
  };

  trustedProjects = [
    "/home/vicenzo"
    "/home/vicenzo/caelestia-src"
    "/home/vicenzo/nixos"
    "/home/vicenzo/spacedrive-nix"
    "/var/lib/spacebot"
  ];

  mkProject = path: {
    name = path;
    value = {
      trust_level = "trusted";
      approval_policy = "never";
      sandbox_mode = "danger-full-access";
    };
  };

  mkServer = command: args: startup: timeout: {
    inherit command args;
    startup_timeout_sec = startup;
    tool_timeout_sec = timeout;
  };

  mkSecretServer = envName: secretPath: command: args: startup: timeout:
    mkServer "${secretEnvRunner}/bin/code-secret-env" ([envName secretPath command] ++ args) startup timeout;

  screenpipeMcpRunner = pkgs.writeShellApplication {
    name = "code-screenpipe-mcp";
    runtimeInputs = [
      pkgs.screenpipe
      pkgs.screenpipe-mcp
    ];
    text = ''
      set -euo pipefail

      token="$(screenpipe auth token | tr -d '\n')"
      if [ -n "$token" ]; then
        export SCREENPIPE_LOCAL_API_KEY="$token"
      fi

      exec screenpipe-mcp "$@"
    '';
  };

  hyprlandServer =
    mkServer
    "${waylandSessionRunner}/bin/code-wayland-session"
    ["${pkgs.hyprmcp}/bin/hyprmcp"]
    30
    120;

  secretPaths = {
    EXA_API_KEY = "/run/secrets/EXA_API_KEY";
    FIRECRAWL_API_KEY = "/run/secrets/FIRECRAWL_API_KEY";
    GITHUB_PERSONAL_ACCESS_TOKEN = "/run/secrets/GITHUB_PERSONAL_ACCESS_TOKEN";
  };

  codeConfig = builtins.readFile ((pkgs.formats.toml {}).generate "code-config.toml" {
    model = "gpt-5.4";
    model_reasoning_effort = "xhigh";
    preferred_model_reasoning_effort = "xhigh";
    service_tier = "fast";
    auto_drive_use_chat_model = false;

    tui = {
      theme = {
        name = "dark-zen-garden";
      };
      auto_review_enabled = false;
    };

    validation.groups = {
      functional = true;
      stylistic = true;
    };

    github.actionlint_on_patch = true;

    projects = builtins.listToAttrs (map mkProject trustedProjects);

    auto_drive = {
      review_enabled = true;
      agents_enabled = true;
      qa_automation_enabled = true;
      cross_check_enabled = true;
      observer_enabled = true;
      coordinator_routing = true;
      model_routing_enabled = true;
      model = "gpt-5.3-codex";
      model_reasoning_effort = "xhigh";
      auto_resolve_review_attempts = 10;
      auto_review_followup_attempts = 10;
      coordinator_turn_cap = 0;
      continue_mode = "sixty-seconds";
      model_routing_entries = [
        {
          model = "gpt-5.3-codex";
          enabled = true;
          reasoning_levels = [
            "high"
            "xhigh"
          ];
          description = "Hard planning and complex problem solving";
        }
      ];
    };

    mcp_servers = {
      exa =
        mkSecretServer
        "EXA_API_KEY"
        secretPaths.EXA_API_KEY
        "${pkgs.codeMcps.exa}/bin/exa-mcp-server"
        ["tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa"]
        45
        120;

      github =
        mkSecretServer
        "GITHUB_PERSONAL_ACCESS_TOKEN"
        secretPaths.GITHUB_PERSONAL_ACCESS_TOKEN
        "${pkgs.github-mcp-server}/bin/github-mcp-server"
        ["stdio"]
        30
        120;

      firecrawl =
        mkSecretServer
        "FIRECRAWL_API_KEY"
        secretPaths.FIRECRAWL_API_KEY
        "${pkgs.codeMcps.firecrawl}/bin/firecrawl-mcp"
        []
        45
        120;

      screenpipe =
        mkServer
        "${screenpipeMcpRunner}/bin/code-screenpipe-mcp"
        []
        60
        180;

      playwright =
        mkServer
        "${pkgs.playwright-mcp}/bin/mcp-server-playwright"
        [
          "--caps"
          "vision"
          "--headless"
          "--viewport-size"
          "1366x768"
          "--executable-path"
          "/etc/profiles/per-user/vicenzo/bin/google-chrome"
          "--isolated"
          "--output-mode"
          "stdout"
        ]
        90
        300;

      hyprland = hyprlandServer;
    };

    features.memories = true;
  });
in {
  home = lib.mkIf enabled {
    home.file.".code/config.toml" = {
      force = true;
      text = codeConfig;
    };

    home.packages = with pkgs; [
      actionlint
      alejandra
      cargo
      deadnix
      eslint
      fd
      github-mcp-server
      jq
      markdownlint-cli
      nil
      nixfmt-rfc-style
      ripgrep
      screenpipe-mcp
      shellcheck
      statix
      typescript
      hyprmcp
    ];
  };

  nixos = lib.mkIf enabled {};
}
