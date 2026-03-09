{theme ? "default"}: let
  defaultColors = rec {
    red = "#f38ba8";
    green = "#a6e3a1";
    blue = "#89b4fa";
    yellow = "#f9e2af";
    teal = "#00ffd0";
    purple = "#ca9ee6";
    lavender = "#";
    cyan = "#8bd5ca";
    sapphire = "#7dc4e4";
    sky = "#91d7e3";
    pink = "#f5bde6";

    Blue = "#643FFF";
  };

  themes = {
    default = defaultColors;

    dark =
      defaultColors
      // {
        green = "006400";
        blue = "00008B";
        red = "8B0000";
        yellow = "CCCC00";
      };

    light =
      defaultColors
      // {
        green = "90EE90";
        blue = "ADD8E6";
        red = "FF6347";
        yellow = "FFD700";
      };

    pastel =
      defaultColors
      // {
        green = "77DD77";
        blue = "AEC6CF";
        red = "FF6961";
        yellow = "FDFD96";
      };
  };
in
  themes.${theme}
