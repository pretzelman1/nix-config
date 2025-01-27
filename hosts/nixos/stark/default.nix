#############################################################
#
#  stark - NixOS Host
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
    inputs.hardware.nixosModules.common-cpu-intel
    # inputs.hardware.nixosModules.common-gpu-amd
    # inputs.hardware.nixosModules.common-pc-ssd

    #################### Disk Layout ####################
    inputs.disko.nixosModules.disko
    (lib.custom.relativeToHosts "common/disks/ext4-disk.nix")
    {
      _module.args = {
        disk = "/dev/sda";
        withSwap = false;
      };
    }

    #################### Misc Inputs ####################
    (map lib.custom.relativeToHosts [
      #################### Required Configs ####################
      "common/core"

      #################### Host-specific Optional Configs ####################
      "common/optional/nixos/services/openssh.nix" # allow remote SSH access
      # "common/optional/nixos/nvtop.nix" # GPU monitor (not available in home-manager)
    ])
  ];

  hostSpec = {
    hostName = "stark";
    hostPlatform = "x86_64-linux";
    disableSops = true;
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      # When using plymouth, initrd can expand by a lot each time, so limit how many we keep around
      configurationLimit = lib.mkDefault 10;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.initrd = {
    systemd.enable = true;
  };

  system.stateVersion = config.hostSpec.system.stateVersion;
}
