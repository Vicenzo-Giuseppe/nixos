_: {
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      wireplumber = {
        enable = true;
        extraConfig."51-alsa-profile" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.name" = "alsa_card.pci-0000_00_1f.3";
                }
              ];
              actions = {
                update-props = {
                  # Keep the internal mic available by default.
                  "device.profile" = "output:analog-stereo+input:analog-stereo";
                };
              };
            }
            {
              matches = [
                {
                  "device.name" = "alsa_card.pci-0000_01_00.1";
                }
              ];
              actions = {
                update-props = {
                  # Auto-enable HDMI audio on the Nvidia card when the TV is connected.
                  "api.acp.auto-port" = true;
                  "api.acp.auto-profile" = true;
                };
              };
            }
          ];
        };
      };
      pulse.enable = true;
    };
  };
}
