{
  configVars,
  configLib,
  ...
}: {
  imports = [
    #################### Required Configs ####################
    common/core # required
    # common/darwin

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/optional/development/java.nix
    common/darwin/optional/aerospace
    common/optional/jupyter-notebook
    common/optional/media/spotify.nix
    common/optional/secrets/kubeconfig.nix
    common/optional/comms
    common/optional/development/ide.nix
    common/optional/development/tilt.nix
  ];

  home = {
    username = configVars.username;
    homeDirectory = configLib.getHomeDirectory configVars.username;
  };
}
