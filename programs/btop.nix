{
  pkgs,
  lib,
  enabled,
  ...
}: let
  theme = "oxocarbon_dark";

  # Palette from nyoom-engineering/oxocarbon.nvim dark mode.
  oxocarbon = {
    base00 = "#161616";
    base01 = "#262626";
    base02 = "#393939";
    base03 = "#525252";
    base04 = "#dde1e6";
    base05 = "#f2f4f8";
    base06 = "#ffffff";
    base07 = "#08bdba";
    base08 = "#3ddbd9";
    base09 = "#78a9ff";
    base10 = "#ee5396";
    base11 = "#33b1ff";
    base12 = "#ff7eb6";
    base13 = "#42be65";
    base14 = "#be95ff";
    base15 = "#82cfff";
  };

  oxocarbonBtopTheme = p: ''
    # Oxocarbon Dark Theme for btop
    # Palette from nyoom-engineering/oxocarbon.nvim

    theme[main_bg]="${p.base00}"
    theme[main_fg]="${p.base04}"
    theme[title]="${p.base12}"
    theme[hi_fg]="${p.base14}"

    theme[selected_bg]="${p.base02}"
    theme[selected_fg]="${p.base12}"
    theme[inactive_fg]="${p.base03}"
    theme[graph_text]="${p.base03}"
    theme[meter_bg]="${p.base01}"

    theme[proc_misc]="${p.base14}"

    theme[cpu_box]="${p.base02}"
    theme[mem_box]="${p.base02}"
    theme[net_box]="${p.base02}"
    theme[proc_box]="${p.base02}"
    theme[div_line]="${p.base01}"

    theme[temp_start]="${p.base09}"
    theme[temp_mid]="${p.base14}"
    theme[temp_end]="${p.base12}"

    theme[cpu_start]="${p.base10}"
    theme[cpu_mid]="${p.base12}"
    theme[cpu_end]="${p.base14}"

    theme[free_start]="${p.base14}"
    theme[free_mid]="${p.base12}"
    theme[free_end]="${p.base10}"

    theme[cached_start]="${p.base09}"
    theme[cached_mid]="${p.base14}"
    theme[cached_end]="${p.base12}"

    theme[available_start]="${p.base14}"
    theme[available_mid]="${p.base12}"
    theme[available_end]="${p.base10}"

    theme[used_start]="${p.base10}"
    theme[used_mid]="${p.base12}"
    theme[used_end]="${p.base14}"

    theme[download_start]="${p.base09}"
    theme[download_mid]="${p.base14}"
    theme[download_end]="${p.base12}"

    theme[upload_start]="${p.base10}"
    theme[upload_mid]="${p.base12}"
    theme[upload_end]="${p.base14}"

    theme[process_start]="${p.base10}"
    theme[process_mid]="${p.base12}"
    theme[process_end]="${p.base14}"
  '';
in {
  home = lib.mkIf enabled {
    programs.btop = {
      enable = true;

      # Keep the NixOS wrapper below as the actual btop command.
      package = null;

      settings = {
        color_theme = theme;
        theme_background = true;
        truecolor = true;
        force_tty = false;

        shown_boxes = "gpu0 proc";
        update_ms = 1700;
        show_gpu_info = "On";
        cpu_graph_upper = "gpu-average";
        cpu_graph_lower = "gpu-totals";
        cpu_invert_lower = true;
      };

      themes.${theme} = oxocarbonBtopTheme oxocarbon;
    };

    xdg.configFile = {
      "btop/btop.conf".force = true;
      "btop/themes/${theme}.theme".force = true;
    };
  };

  nixos = lib.mkIf enabled {
    security.wrappers.btop = {
      owner = "root";
      group = "root";
      capabilities = "cap_perfmon,cap_sys_admin,cap_net_raw+ep";
      source = "${pkgs.btop.override {cudaSupport = true;}}/bin/btop";
    };
  };
}
