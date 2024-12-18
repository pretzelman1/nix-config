{
  configVars,
  configLib,
  ...
}: {
  imports = [
    #################### Required Configs ####################
    common/core
    common/darwin/core

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
    common/optional/development/aws.nix
    common/optional/development/node.nix
    common/optional/development/misc-language-servers.nix
    common/optional/secrets/ssh/server.nix
  ];

  home = {
    username = configVars.username;
    homeDirectory = configLib.getHomeDirectory configVars.username;
  };
}
