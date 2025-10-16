{ config, pkgs, ... }:
let
  grep = pkgs.gnugrep;
  desiredFlatpaks = [
    "org.signal.Signal"
  ];
in {
  home.activation.flatpakManagement = config.lib.dag.entryAfter ["writeBoundary"] ''
    # Ensure the Flathub repo is added
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --user flathub \
      https://flathub.org/repo/flathub.flatpakrepo

    # Get currently installed Flatpaks
    installedFlatpaks=$(${pkgs.flatpak}/bin/flatpak list --user --app --columns=application)

    # Remove any Flatpaks that are not in the desired list
    for installed in $installedFlatpaks; do
      if ! echo ${toString desiredFlatpaks} | ${grep}/bin/grep -q $installed; then
        echo "Removing $installed because it's not in the desiredFlatpaks list."
        ${pkgs.flatpak}/bin/flatpak uninstall --user -y --noninteractive $installed
      fi
    done

    # Install or re-install Flatpaks in desired list
    for app in ${toString desiredFlatpaks}; do
      echo "Ensuring $app is installed."
      ${pkgs.flatpak}/bin/flatpak install --user -y flathub $app
    done

    # Remove unused Flatpaks
    ${pkgs.flatpak}/bin/flatpak uninstall --user --unused -y

    # Update all installed Flatpaks
    ${pkgs.flatpak}/bin/flatpak update --user -y

    # Set Signal to use KWallet for encrypted password storage
    ${pkgs.flatpak}/bin/flatpak override --user --env=SIGNAL_PASSWORD_STORE=kwallet6 org.signal.Signal
  '';
}