{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.hermine-server.gpuPassthrough;

  hookScript = pkgs.writeScriptBin "qemu-hook-gpu" ''
    #!/usr/bin/env bash
    # libvirt qemu hook — dynamic GPU bind/unbind
    # Installed to /var/lib/libvirt/hooks/qemu

    GUEST_NAME="$1"
    OPERATION="$2"

    [ "$GUEST_NAME" != "${cfg.vmName}" ] && exit 0

    GPU_DEVICE="0000:01:00.0"
    GPU_AUDIO="0000:01:00.1"

    # Unbind from nvidia, bind to vfio-pci before VM starts
    if [ "$OPERATION" = "prepare" ]; then
      # Clear driver override before unbinding
      echo "" > /sys/bus/pci/devices/$GPU_DEVICE/driver_override
      echo "" > /sys/bus/pci/devices/$GPU_AUDIO/driver_override
      # Unbind from current drivers
      echo "$GPU_DEVICE" > /sys/bus/pci/drivers/nvidia/unbind
      echo "$GPU_AUDIO" > /sys/bus/pci/drivers/snd_hda_intel/unbind 2>/dev/null || true
      # Set new driver override and bind
      echo "vfio-pci" > /sys/bus/pci/devices/$GPU_DEVICE/driver_override
      echo "vfio-pci" > /sys/bus/pci/devices/$GPU_AUDIO/driver_override
      echo "$GPU_DEVICE" > /sys/bus/pci/drivers/vfio-pci/bind
      echo "$GPU_AUDIO" > /sys/bus/pci/drivers/vfio-pci/bind

    # Unbind from vfio-pci, rebind to nvidia after VM stops
    elif [ "$OPERATION" = "release" ]; then
      # Clear driver override before unbinding
      echo "" > /sys/bus/pci/devices/$GPU_DEVICE/driver_override
      echo "" > /sys/bus/pci/devices/$GPU_AUDIO/driver_override
      # Unbind from vfio-pci
      echo "$GPU_DEVICE" > /sys/bus/pci/drivers/vfio-pci/unbind
      echo "$GPU_AUDIO" > /sys/bus/pci/drivers/vfio-pci/unbind
      # Set nvidia override for GPU, clear for audio (handled by snd_hda_intel)
      echo "nvidia" > /sys/bus/pci/devices/$GPU_DEVICE/driver_override
      echo "" > /sys/bus/pci/devices/$GPU_AUDIO/driver_override
      # Rebind to nvidia and audio drivers
      echo "$GPU_DEVICE" > /sys/bus/pci/drivers/nvidia/bind
      echo "$GPU_AUDIO" > /sys/bus/pci/drivers/snd_hda_intel/bind 2>/dev/null || true
    fi
  '';
in
{
  options.hardware.hermine-server.gpuPassthrough.vmName = lib.mkOption {
    type = lib.types.str;
    default = "gpu-vm";
    description = "Name of the libvirt VM that gets GPU passthrough";
  };

  config = {
    # Ensure vfio-pci driver is available
    boot.kernelModules = [ "vfio-pci" "vfio" "vfio_iommu_type1" ];

    # Install the hook script
    environment.systemPackages = [ hookScript ];

    # Ensure libvirt hook directory exists before placing the symlink
    systemd.tmpfiles.rules = [
      "d /var/lib/libvirt/hooks 0755 root root -"
      "L+ /var/lib/libvirt/hooks/qemu - - - - ${hookScript}/bin/qemu-hook-gpu"
    ];
  };
}
