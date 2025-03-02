{
  pkgs,
  lib,
  ...
}: {
  services.sketchybar = {
    enable = true;

    extraPackages = with pkgs; [
      jq
      aerospace
    ];
  };

  # Hide the macos menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce true;
}
