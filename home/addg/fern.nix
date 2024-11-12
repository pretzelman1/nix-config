{
  configVars,
  configLib,
  ...
}: {
  imports = [
    #################### Required Configs ####################
    common/core # required
    common/darwin

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/darwin/optional/aerospace
    common/optional/jupyter-notebook
    common/optional/media/spotify.nix
  ];

  home = {
    username = configVars.username;
    homeDirectory = configLib.getHomeDirectory configVars.username;
  };
}
