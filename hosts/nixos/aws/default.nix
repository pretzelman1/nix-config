#############################################################
#
#  zephy - Main Desktop
#  NixOS running on Ryzen 5 3600X, Radeon RX 5700 XT, 64GB RAM
#
###############################################################
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = lib.flatten [
    #################### Every Host Needs This ####################
    # ./hardware-configuration.nix

    #################### Hardware Modules ####################
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-gpu-amd
    # inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    # inputs.disko.nixosModules.disko
    # (lib.custom.relativeToHosts "common/disks/standard-disk-config.nix")
    # {
    #   _module.args = {
    #     disk = "/dev/nvme0n1";
    #     withSwap = false;
    #   };
    # }

    #################### Misc Inputs ####################
    (map lib.custom.relativeToHosts [
      #################### Required Configs ####################
      "common/core"

      #################### Host-specific Optional Configs ####################
      # "common/optional/nixos/services/openssh.nix" # allow remote SSH access
    ])
  ];

  hostSpec = {
    hostName = "aws";
    hostPlatform = "x86_64-linux";
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  system.stateVersion = config.hostSpec.system.stateVersion;
}
