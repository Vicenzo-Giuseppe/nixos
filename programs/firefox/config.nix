{
  lib,
  ...
}: let
  nixIcon = "https://nixos.org/logo/nix-wiki.png";
  removeEngines = [
    "Amazon.com"
    "Bing"
    "DuckDuckGo"
    "Wikipedia (en)"
  ];
  catppuccin = {
    "{8446b178-c865-4f5c-8ccc-1d7887811ae3}" = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_lavender.xpi";
  };
  extensions = {
    darkreader = "addon@darkreader.org";
    styl-us = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
    nighttab = "{47bf427e-c83d-457d-9b3d-3db4118574bd}";
    ublock-origin = "uBlock0@raymondhill.net";
  };
  searchEngines = {
    github = {
      Name = "GitHub";
      Description = "Search GitHub";
      URLTemplate = "https://github.com/search?q={searchTerms}";
      Method = "GET";
      IconURL = "https://github.com/favicon.ico";
      Alias = "github";
    };
    nix-source = {
      Name = "Sourcegraph/Nix";
      Description = "Sourcegraph nix search";
      Alias = "nix";
      Method = "GET";
      IconURL = "https://sourcegraph.com/.assets/img/sourcegraph-mark.svg?v2";
      URLTemplate = "https://sourcegraph.com/search?q=context:global+file:.nix%24+{searchTerms}&patternType=literal";
    };
    crates-io = {
      Name = "Crates.io";
      Description = "Rust crates";
      Alias = "crates";
      Method = "GET";
      IconURL = "https://crates.io/assets/cargo.png";
      URLTemplate = "https://crates.io/search?q={searchTerms}";
    };
    blockchair = {
      Name = "Blockchair";
      Description = "Blockchain Explorer";
      Alias = "chain";
      Method = "GET";
      IconURL = "https://loutre.blockchair.io/assets/svg/logo-black.svg";
      URLTemplate = "https://blockchair.com/search?q={searchTerms}";
    };
    invidious = {
      Name = "Invidious";
      Description = "Search for videos, channels, and playlists on Invidious";
      URLTemplate = "https://invidious.sethforprivacy.com/search?q={searchTerms}";
      Method = "GET";
      IconURL = "https://invidious.snopyta.org/favicon.ico";
      Alias = "yt";
    };
    home-manager = {
      Name = "NixOS HomeManager";
      Description = "Search Home Manager Options";
      Alias = "hm";
      Method = "GET";
      IconURL = nixIcon;
      URLTemplate = "https://mipmip.github.io/home-manager-option-search?{searchTerms}";
    };
    nixos-options = {
      Name = "NixOS options";
      Description = "Search NixOS options.";
      URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
      Method = "GET";
      IconURL = nixIcon;
      Alias = "options";
    };
    nixos-packages = {
      Name = "NixOS Packages";
      Description = "Search NixOS Packages";
      Alias = "pkgs";
      IconURL = nixIcon;
      Method = "GET";
      URLTemplate = "https://search.nixos.org/packages?&query={searchTerms}";
    };
  };
  forceInstalledExtensions =
    lib.mapAttrs'
    (
      name: id:
        lib.nameValuePair id "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi"
    )
    extensions
    // catppuccin;
in {
  output = {
    profileName = "vicenzo";
    policies = {
      CaptivePortal = false;
      DisableAppUpdate = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableForgetButton = true;
      DisableFormHistory = true;
      DisableMasterPasswordCreation = true;
      DisablePasswordReveal = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DisableSystemAddonUpdate = true;
      DisplayBookmarksToolbar = "newtab";
      PopupBlocking = {
        Default = true;
        Locked = false;
      };
      PictureInPicture = {
        Enabled = false;
        Locked = false;
      };
      PromptForDownloadLocation = true;
      DisplayMenuBar = "default-off";
      DontCheckDefaultBrowser = true;
      SearchEngines = {
        Remove = removeEngines;
        Add = builtins.attrValues searchEngines;
        Default = "Google";
        PreventInstalls = true;
      };
      ExtensionSettings =
        builtins.mapAttrs
        (_: url: {
          install_url = url;
          installation_mode = "force_installed";
        })
        (forceInstalledExtensions
          // {
            "*" = {
              installation_mode = "blocked";
              blocked_install_message = "manage extensions via nix";
            };
          });
      FirefoxHome = {
        Search = true;
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };
      PasswordManagerEnabled = false;
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
        WhatsNew = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        MoreFromMozilla = false;
        locked = true;
      };
      OfferToSaveLogins = false;
      PDFjs = {
        Enabled = true;
        EnablePermissions = false;
      };
      SanitizeOnShutdown = {
        Cache = false;
        History = false;
        Cookies = false;
        Downloads = true;
        FormData = true;
        Sessions = false;
        OfflineApps = false;
      };
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      HardwareAcceleration = true;
    };
  };
}
