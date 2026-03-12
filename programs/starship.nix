{
  user,
  lib,
  enabled,
  ...
}:
let
  username = with lib; toUpper (substring 0 1 user) + substring 1 (-1) user;
in
{
  home =
    { colors, ... }:
    lib.mkIf enabled {
      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = with colors { }; {
          add_newline = false;
          format = lib.concatStrings [
            "$username"
            "$hostname"
            # "$os"
            # "$battery"
            # "$shlvl"
            # "$directory"
            # "$git_branch"
            # "$git_commit"
            # "$git_state"
            # "$git_status"
            # "$hg_branch"
            # "$custom"
            # "$docker_context"
            # "$package"
            # "$cmake"
            # "$dart"
            # "$dotnet"
            # "$elixir"
            # "$lua"
            # "$elm"
            # "$erlang"
            # "$golang"
            # "$helm"
            # "$java"
            # "$julia"
            # "$kotlin"
            # "$nim"
            # "$nodejs"
            # "$ocaml"
            # "$perl"
            # "$php"
            # "$purescript"
            # "$python"
            # "$ruby"
            # "$rust"
            # "$swift"
            # "$terraform"
            # "$vagrant"
            # "$zig"
            # "$nix_shell"
            # "$sudo"
            # "$conda"
            # "$memory_usage"
            # "$aws"
            # "$gcloud"
            # "$openstack"
            # "$env_var"
            # "$crystal"
            # "$cmd_duration"
            # "$fill"
            # "$time"
            # "$line_break"
            # "$jobs"
            # "$status"
            # "$character"
          ];
          scan_timeout = 10;
          character = {
            success_symbol = "[λ](bold ${cyan})";
            error_symbol = "[λ](bold ${red})";
            vicmd_symbol = "[ ](bold ${purple})";
          };
          username = {
            style_user = "fg:bold italic ${pink}";
            show_always = true;
            format = "[${username}]($style) ";
          };
          directory = {
            truncation_length = 10;
            truncate_to_repo = false;
            style = "
          fg:bold ${sky} bg:${Blue}
        ";
            format = "[:: ](bold  ${lavender} )[$path ]($style)[$read_only]($read_only_style) ";
          };
          docker_context = {
            format = "via [🐋 $context](${blue} bold)";
          };
          elixir = {
            format = "🔮 ";
          };
          git_branch = {
            symbol = "🌱 ";
            truncation_length = 4;
            truncation_symbol = "";
            ignore_branches = [
              "master"
              "main"
            ];
          };
          git_commit = {
            commit_hash_length = 4;
            tag_symbol = "🔖 ";
          };
          git_state = {
            format = "[\($state( $progress_current of $progress_total)\)]($style) ";
            cherry_pick = "[🍒 PICKING](bold ${red})";
          };
          git_metrics = {
            added_style = "bold ${blue}";
            format = "[+$added]($added_style)/[-$deleted]($deleted_style) ";
          };
          git_status = {
            conflicted = "🏳";
            ahead = "🏎💨";
            behind = "😰";
            diverged = "😵";
            up_to_date = "✓";
            untracked = "🤷";
            stashed = "📦";
            modified = "📝";
            staged = "[++\($count\)](${green})";
            renamed = "👅";
            deleted = "🗑";
          };
          openstack = {
            format = "on [$symbol$cloud(\\($project\\))]($style) ";
            style = "bold ${yellow}";
            symbol = "☁️ ";
          };
          python = {
            symbol = "👾 ";
            pyenv_version_name = true;
          };
          sudo = {
            style = "bold ${green}";
            symbol = "🚀";
            format = "$symbol";
            disabled = false;
          };
          lua = {
            format = "via [🌕 $version](bold ${blue}) ";
          };
          ruby = {
            symbol = "🔺 ";
          };
          fill = {
            style = "italic bold ${teal}";
          };
          custom.readme = {
            detect_files = [
              "README.md"
              "readme.org"
            ];
            style = "${sapphire}";
            symbol = " ";
            command = "";
            format = "[$symbol $output]($style)";
          };
          custom.deno = {
            detect_files = [
              "deno.json"
              "imports.json"
              "import_map.json"
            ];
            style = "";
            symbol = "🦕";
            command = "";
            format = "[$symbol $output]($style)";
          };
          os = {
            disabled = false;
          };
          os.symbols = {
            NixOS = "[ ](fg:${blue})";
          };
          nix_shell = {
            format = "[$state(\($name\))]($style) ";
            style = "bold italic ${teal}";
            impure_msg = "";
            pure_msg = "󱗿";
            unknown_msg = "";
            heuristic = true;
          };
          battery = {
            full_symbol = "󰁹";
            charging_symbol = "󰂄";
            discharging_symbol = "󰂃";
            empty_symbol = "󰂎";
            format = "[$symbol]($style) ";
            display = [
              {
                threshold = 10;
                style = "bold ${red}";
                discharging_symbol = "*";
                charging_symbol = " 󰢜";
              }
              {
                threshold = 20;
                style = "bold ${yellow}";
                discharging_symbol = "*";
                charging_symbol = " 󰂆";
              }
              {
                threshold = 30;
                style = "bold ${blue}";
                discharging_symbol = "*";
                charging_symbol = " 󰂇";
              }
              {
                threshold = 50;
                style = "bold ${teal}";
                discharging_symbol = "*";
                charging_symbol = " 󰢝";
              }
            ];
          };
        };
      };
    };
  nixos = lib.mkIf enabled { };
}
