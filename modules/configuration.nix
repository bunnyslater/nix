{ config, pkgs, lib, ... }:

let
in
{

  # Configure virtualisation, enable libvirt and podman.
  virtualisation = lib.mkIf globals.enableVirtualization {
    kvmgt = {
      enable = true;
      vgpus = {
        "i915-GVTg_V5_4" = {
          uuid = [ "d54eb6bc-fbca-11f0-a64b-3345f66e8e9e" ];
        };
      };
    };
  };

}
