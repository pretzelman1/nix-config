{
  pkgs,
  config,
  lib,
  configVars,
  configLib,
  ...
}: {
  config = lib.mkIf (pkgs.stdenv.isLinux) {
    users.users.root = {
      shell = pkgs.zsh;
      hashedPasswordFile = config.users.users.${configVars.username}.hashedPasswordFile;
      password = lib.mkForce config.users.users.${configVars.username}.password;
      # root's ssh keys are mainly used for remote deployment.
      openssh.authorizedKeys.keys = config.users.users.${configVars.username}.openssh.authorizedKeys.keys;
    };

    # Setup oh-my-posh for root
    home-manager.users.root = lib.optionalAttrs (!configVars.isMinimal) {
      home.stateVersion = "23.05"; # Avoid error
      imports = lib.flatten [
        (
          map configLib.relativeToHome [
            "${configVars.username}/common/core/cli/themes/oh-my-posh"
          ]
        )
      ];
    };
  };
}
