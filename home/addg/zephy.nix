{config, lib, ...}: {
  imports = [
    #################### Required Configs ####################
    common/core # required

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/optional/jupyter-notebook
    common/optional/nixos/desktops # default is hyprland
    common/optional/development/ide.nix
    common/optional/media/spotify.nix
    common/optional/gaming
    common/optional/comms
    common/optional/browsers
    common/optional/ghostty
    common/optional/1password.nix
  ];

  home = {
    username = config.hostSpec.username;
    homeDirectory = lib.custom.getHomeDirectory config.hostSpec.username;
  };
  
  #
  # ========== Host-specific Monitor Spec ==========
  #
  # This uses the nix-config/modules/home-manager/montiors.nix module which defaults to enabled.
  # Your nix-config/home-manger/<user>/common/optional/desktops/foo.nix WM config should parse and apply these values to it's monitor settings
  # If on hyprland, use `hyprctl monitors` to get monitor info.
  # https://wiki.hyprland.org/Configuring/Monitors/
  #           ------
  #        | HDMI-A-1 |
  #           ------
  #  ------   ------   ------
  # | DP-2 | | DP-1 | | DP-3 |
  #  ------   ------   ------
  monitors = [
    {
      name = "DP-1";
      width = 2560;
      height = 1600;
      refreshRate = 165;
      primary = true;
    }
    {
      name = "DP-2";
      width = 3840;
      height = 1100;
      refreshRate = 60;
      y = 1600;
      workspace = "0";
    }
  ];
}
