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
    ./hardware-configuration.nix

    #################### Hardware Modules ####################
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-gpu-amd
    # inputs.hardware.nixosModules.common-pc-ssd

    #################### Misc Inputs ####################
    (map lib.custom.relativeToHosts [
      #################### Required Configs ####################
      "common/core"
      "common/nixos/core"

      #################### Host-specific Optional Configs ####################
      "common/nixos/optional/services/openssh.nix" # allow remote SSH access
      "common/nixos/optional/nvtop.nix" # GPU monitor (not available in home-manager)
    ])
  ];

  networking = {
    hostName = "stark";
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    # systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  system.stateVersion = config.hostSpec.system.stateVersion;
}
