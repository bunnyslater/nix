{ lib, globals, username, pkgs, ... }: let
  username = globals.username;
in {
  # Configures:
  ### Extensions, including: 
  #### Ublock Origin, Consent-o-Matic, 1Password, Decentraleyes, DarkReader, Linkding, Yomitan 
  #### Tree Style Tab, Open Multiple URLs, Export Tabs URLs, SingleFile, SponsorBlock, Control Panel for Twitter, Open Temp Container
  ### And a number of preferences:
  #### Disable telemetry, syncing, password manager, stories, 'More from Mozilla' in settings
  #### Disable ads, stories, sponsored stories, top sites and sponsored top sites from new tab page
  #### Set UI to compact mode
  programs.firefox = {
  enable = true;
  policies = {
    DontCheckDefaultBrowser = true;
    DisableFirefoxAccounts = true;
    DisableFirefoxStudies = true;
    DisableTelemetry = true;
    NoDefaultBookMarks = true;
    PasswordManagerEnabled = false;
    ExtensionSettings = {
      "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
        default_area = "menupanel";
        install_url = "http://addons.mozilla.org/firefox/downloads/latest/linkding-extension/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "{4908d5d9-b33e-4cae-9cfe-9d7093ae4d9b}" = {
        default_area = "menupanel";
        install_url = "http://addons.mozilla.org/firefox/downloads/latest/open-temp-container/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "uBlock0@raymondhill.net" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = true;
      };
      "gdpr@cavi.au.dk" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = true;
      };
      "jid1-BoFifL9Vbdl2zQ@jetpack" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = true;
      };
      "addon@darkreader.org" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/single-file/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "openmultipleurls@ustat.de" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/open-multiple-tab-urls/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = true;
      };
      "{17165bd9-9b71-4323-99a5-3d4ce49f3d75}" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/export-tabs-urls-and-titles/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = true;
      };
      "sponsorBlocker@ajay.app" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "{5cce4ab5-3d47-41b9-af5e-8203eea05245}" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/control-panel-for-twitter/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "{6b733b82-9261-47ee-a595-2dda294a4d08}" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/yomitan/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
      "treestyletab@piro.sakura.ne.jp" = {
        default_area = "menupanel";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
        installation_mode = "force_installed";
        private_browsing = false;
      };
    };
    FirefoxHome = {
      TopSites = false;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      Stories = false;
      SponsoredPocket = false;
      SponsoredStories = false;
    };
    Preferences = {
      "browser.uidensity" = {
        "Value" = 1;
        "Status" = "default";
        "Type" = "number";
      };
      "browser.aboutConfig.showWarning" = {
        "Value" = false;
        "Type" = "locked";
      };
    };
    UserMessaging.MoreFromMozilla = false;
    ReqestedLocales = "en-GB,fr";
  };
};
}