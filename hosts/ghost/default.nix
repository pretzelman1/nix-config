#############################################################
#
#  ghost - Main Desktop
#  MacOS running on M3 Max, 64GB RAM
#
###############################################################
{
  inputs,
  lib,
  configVars,
  config,
  configLib,
  pkgs,
  ...
}: {
  imports = lib.flatten [
    (map configLib.relativeToHosts [
      #################### Required Configs ####################
      "common/core"
      "common/darwin/core"

      #################### Host-specific Optional Configs ####################

      #################### Desktop ####################

      "common/users/addg"
    ])
  ];

  networking.hostName = "ghost";
  networking.computerName = config.networking.hostName;
  system.defaults.smb.NetBIOSName = config.networking.hostName;

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = 4;
}
