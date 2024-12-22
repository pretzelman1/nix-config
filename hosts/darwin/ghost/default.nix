#############################################################
#
#  ghost - Main Desktop
#  MacOS running on M4 Max, 128GB RAM
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
    (map lib.custom.relativeToHosts [
      #################### Required Configs ####################
      "common/core"
      "common/darwin/core"

      #################### Host-specific Optional Configs ####################

      #################### Desktop ####################

      "common/users/addg"
    ])
  ];

  hostSpec = {
    hostName = "ghost";
    isDarwin = true;
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
