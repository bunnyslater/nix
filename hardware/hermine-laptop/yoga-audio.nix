{ config, pkgs, ... }:

let
  fourPaBypass = pkgs.writeShellScriptBin "4pa-bypass.sh" ''
    #!/bin/bash

    tas2781_i2c_addr=(0x38 0x39 0x3b 0x3d)

    for value in "$''${tas2781_i2c_addr[@]}"; do
      i2cset -f -y 3 "$value" 0x00 0x00
      i2cset -f -y 3 "$value" 0x7f 0x00
      i2cset -f -y 3 "$value" 0x01 0x01
      i2cset -f -y 3 "$value" 0x0e 0xc4
      i2cset -f -y 3 "$value" 0x0f 0x40
      i2cset -f -y 3 "$value" 0x5c 0xd9
      i2cset -f -y 3 "$value" 0x60 0x10
      i2cset -f -y 3 "$value" 0x0a 0x2e
      i2cset -f -y 3 "$value" 0x0d 0x01
      i2cset -f -y 3 "$value" 0x16 0x40
      i2cset -f -y 3 "$value" 0x00 0x01
      i2cset -f -y 3 "$value" 0x17 0xc8
      i2cset -f -y 3 "$value" 0x00 0x04
      i2cset -f -y 3 "$value" 0x30 0x00
      i2cset -f -y 3 "$value" 0x31 0x00
      i2cset -f -y 3 "$value" 0x32 0x00
      i2cset -f -y 3 "$value" 0x33 0x01

      i2cset -f -y 3 "$value" 0x00 0x08
      i2cset -f -y 3 "$value" 0x18 0x00
      i2cset -f -y 3 "$value" 0x19 0x00
      i2cset -f -y 3 "$value" 0x1a 0x00
      i2cset -f -y 3 "$value" 0x1b 0x00
      i2cset -f -y 3 "$value" 0x28 0x40
      i2cset -f -y 3 "$value" 0x29 0x00
      i2cset -f -y 3 "$value" 0x2a 0x00
      i2cset -f -y 3 "$value" 0x2b 0x00

      i2cset -f -y 3 "$value" 0x00 0x0a
      i2cset -f -y 3 "$value" 0x48 0x00
      i2cset -f -y 3 "$value" 0x49 0x00
      i2cset -f -y 3 "$value" 0x4a 0x00
      i2cset -f -y 3 "$value" 0x4b 0x00
      i2cset -f -y 3 "$value" 0x58 0x40
      i2cset -f -y 3 "$value" 0x59 0x00
      i2cset -f -y 3 "$value" 0x5a 0x00
      i2cset -f -y 3 "$value" 0x5b 0x00

      i2cset -f -y 3 "$value" 0x00 0x00
      i2cset -f -y 3 "$value" 0x02 0x00
    done
  '';
in
{
  environment.systemPackages = with pkgs; [
    util-linux
    kmod
    i2c-tools
    fourPaBypass
  ];

  boot.kernelModules = [ "i2c-dev" ];

  systemd.services.turn-on-speakers = {
    description = "Turn on speakers using i2c configuration";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];

    serviceConfig = {
      User = "root";
      Type = "oneshot";
      Environment = "PATH=${pkgs.i2c-tools}/bin:${pkgs.kmod}/bin:${pkgs.util-linux}/bin";
      ExecStart = "${pkgs.bash}/bin/bash -c '${fourPaBypass}/bin/4pa-bypass.sh | ${pkgs.util-linux}/bin/logger'";
    };

    wantedBy = [ "multi-user.target" "sleep.target" ];
  };
}
