{
  inputs,
  lib,
  enabled,
  pkgs,
  ...
}:
let
  inherit (inputs) opencode;
in
{
  home =
    { config, ... }:
    with builtins;
    let
      env = config.sops.secrets;
      inherit ((import ./agents-md/mkAgent.nix { inherit (pkgs) lib; })) mkAgent;
    in
    lib.mkIf enabled {
      programs.opencode = {
        enable = true;
        package = opencode.packages.x86_64-linux.default;
        commands = {
          plan = ./commands-md/plan-notator.md;
          #research = ./commands-md/research-advanced.md;
        };

        settings = {
          plugin = [
            "@simonwjackson/opencode-direnv"
            "@plannotator/opencode@latest"
            #"@spoons-and-mirrors/subtask2@latest"
            "opencode-smart-voice-notify@latest"
          ];
        };

        agents = {
          Researcher = mkAgent ./agents-md/Researcher.md {
            default = true;
            mode = "subagent";
            model = "kimi-for-coding/k2p5";
            description = "Researcher Agent - Outputs research findings as MD files";
            temperature = 0.8;
          };
          Architect = mkAgent ./agents-md/Architect.md {
            disable = true;
            default = true;
            mode = "primary";
            model = "kimi-for-coding/k2p5";
            description = "Master Orchestrator - coordinates specialized agents (Researcher, Explorer, Coder ) to execute complex multi-agent workflows with full MCP server integration";
            temperature = 0.3;
          };
          Coder = mkAgent ./agents-md/Coder.md {
            default = true;
            disable = true;
            mode = "subagent";
            model = "kimi-for-coding/k2p5";
            description = "Coder subagent - comprehensive programming knowledge, reads research, implements code, uses NixOS MCP";
            temperature = 0.7;
          };
          #plan = mkAgent ./agents-md/plan.md {
          #  disable = false;
          #  default = false;
          #  mode = "primary";
          #  description = "Builder";
          #};
          #build = mkAgent ./agents-md/build.md {
          #  disable = false;
          #  default = false;
          #  mode = "primary";
          #  description = "Planner";
          #};
          #Writer = mkAgent ./subagents/Writer.md {
          #  default = true;
          #  description = "Main Writer agent - the UNIVERSAL BUILDER that can construct ANYTHING prompted (websites, car engines, software functions) without managing MD repos";
          #  mode = "subagent";
          #  temperature = 0.2;
          #};
        };

        settings.mcp = {
          nixos = {
            enabled = true;
            command = [
              "nix"
              "run"
              "github:utensils/mcp-nixos"
              "--"
            ];
            type = "local";
          };
          exa = {
            enabled = true;
            command = [
              "npx"
              "-y"
              "exa-mcp-server"
              "tools=web_search_exa,get_code_context_exa,crawling_exa,company_research_exa"
            ];
            type = "local";
            environment = {
              # EXA_API_KEY = readFile env.EXA_API_KEY.path;
            };
          };
          github = {
            enabled = true;
            command = [
              "npx"
              "-y"
              "@modelcontextprotocol/server-github"
            ];
            type = "local";
            environment = {
              # GITHUB_PERSONAL_ACCESS_TOKEN = readFile env.GITHUB_PERSONAL_ACCESS_TOKEN.path;
            };
          };
          blender = {
            enabled = true;
            command = [
              "uvx"
              "blender-mcp"
            ];
            type = "local";
          };
          firecrawl = {
            enabled = true;
            type = "local";
            command = [
              "npx"
              "-y"
              "firecrawl-mcp"
            ];
            environment = {
              # FIRECRAWL_API_KEY = readFile env.FIRECRAWL_API_KEY.path;
            };
          };
          firefox-mcp = {
            enabled = true;
            type = "local";
            command = [
              "npx"
              "-y"
              "firefox-devtools-mcp@latest"
              #"--headless"
              "--viewport"
              "1280x720"
            ];
          };
        };

        settings.provider = {
          kimi-for-coding = {
            models = {
              k2p5 = {
                variants = {
                  fmax = {
                    name = "Kimi K2.5-Full";
                    options = {
                      thinking = {
                        type = "enabled";
                        budget_tokens = 16000;
                      };
                      stream = true;
                      max_tokens = 16000;
                      temperature = 1.0;
                    };
                  };
                  fmin = {
                    name = "Kimi mini";
                  };
                };
              };
            };
            options = {
              stream = true;
              #apiKey = readFile env.KIMI_CLI_KEY.path;
            };
          };
        };
      };
    };

  nixos = lib.mkIf enabled {
    #opencode serve localhost throught LAN
    services = {
      tailscale = {
        enable = false;
        useRoutingFeatures = "server"; # Permite roteamento de sub-rede se precisar
        extraSetFlags = [
          "--advertise-exit-node"
          "--accept-dns"
        ];
      };

      avahi = {
        enable = false;
        nssmdns = true; # or nssmdns4 for IPv4-only if you have IPv6 issues
        publish = {
          enable = true;
          addresses = true;
          userServices = true; # Allow user services to advertise
        };
        openFirewall = true; # Opens port 5353 for mDNS
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 4096 ];
}
