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

    # common/optional/xdg.nix # file associations
    # common/optional/sops.nix
  ];

  home = {
    username = configVars.username;
    homeDirectory = "/Users/${configVars.username}";
  };
}
