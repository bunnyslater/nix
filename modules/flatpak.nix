# home.nix
{ lib, ... }: {

  # Add a new remote. Keep the default one (flathub)
  services.flatpak.remotes = lib.mkOptionDefault [{
    name = "flathub";
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  }];

  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = false;

  # Add here the flatpaks you want to install
  services.flatpak.packages = [
    "org.signal.Signal"
    "it.mijorus.gearlever"
    #{ appId = "com.brave.Browser"; origin = "flathub"; }
    #"com.obsproject.Studio"
    #"im.riot.Riot"
  ];

}
