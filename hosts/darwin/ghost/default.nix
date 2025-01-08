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
  isDarwin,
  ...
}: {
  imports = lib.flatten [
    (map lib.custom.relativeToHosts [
      #################### Required Configs ####################
      "common/core"

      #################### Host-specific Optional Configs ####################
      "common/optional/darwin/ghostty"

      #################### Desktop ####################
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
