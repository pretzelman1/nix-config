{
  configVars,
  configLib,
  ...
}: {
  imports = [
    #################### Required Configs ####################
    common/core # required

    #################### Host-specific Optional Configs ####################
    common/optional/helper-scripts
    common/optional/jupyter-notebook
  ];

  home = {
    username = configVars.username;
    homeDirectory = configLib.getHomeDirectory configVars.username;
  };
}
