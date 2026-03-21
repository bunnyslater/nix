{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # This specific line installs the Waydroid package and enables the service
  virtualisation.waydroid.enable = true;
  
  # Network configuration for Waydroid
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
