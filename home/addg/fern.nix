{ configVars, ... }:
{
  imports = [
    #################### Required Configs ####################
    common/core # required
    common/darwin

    #################### Host-specific Optional Configs ####################
    # common/optional/browsers
    # common/optional/desktops # default is hyprland
    # common/optional/comms
    # common/optional/helper-scripts
    # common/optional/gaming
    # common/optional/media
    # common/optional/tools
    common/darwin/optional/aerospace

    # common/optional/xdg.nix # file associations
    # common/optional/sops.nix
  ];

  home = {
    username = configVars.username;
    homeDirectory = "/Users/${configVars.username}";
  };
}
