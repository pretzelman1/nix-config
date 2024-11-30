#############################################################
#
#  zephy - Main Desktop
#  NixOS running on Ryzen 5 3600X, Radeon RX 5700 XT, 64GB RAM
#
###############################################################
{
  inputs,
  lib,
  configVars,
  configLib,
  pkgs,
  ...
}: {
  imports = lib.flatten [
    #################### Every Host Needs This ####################
    ./hardware-configuration.nix

    #################### Hardware Modules ####################
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (configLib.relativeToHosts "common/nixos/disks/standard-disk-config.nix")
    {
      _module.args = {
        disk = "/dev/nvme0n1";
        withSwap = false;
      };
    }

    #################### Misc Inputs ####################
    (map configLib.relativeToHosts [
      #################### Required Configs ####################
      "common/core"
      "common/nixos/core"

      #################### Host-specific Optional Configs ####################
      "common/nixos/optional/services/openssh.nix" # allow remote SSH access
      "common/nixos/optional/nvtop.nix" # GPU monitor (not available in home-manager)

      "common/users/addg"
    ])
  ];

  networking = {
    hostName = "worker-1";
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
