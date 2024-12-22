{config, ...}: {
  imports = [
    #################### Required Configs ####################
    common/core # required

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/darwin/optional/aerospace
    common/optional/jupyter-notebook
    common/optional/media/spotify.nix
  ];

  home = {
    username = config.hostSpec.username;
    homeDirectory = lib.custom.getHomeDirectory config.hostSpec.username;
  };
}
