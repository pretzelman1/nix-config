{
  pkgs,
  inputs,
  config,
  lib,
  configVars,
  configLib,
  ...
}: let
  userConfig = configLib.genUser {
    user = "root";
    linuxConfig = {
      users.users.root = {
        hashedPasswordFile = config.users.users.${configVars.username}.hashedPasswordFile;
        password = lib.mkForce config.users.users.${configVars.username}.password;
      };
    };
    pubKeys = config.users.users.${configVars.username}.openssh.authorizedKeys.keys;
    homeManagerConfig = {
      home-manager.users.root = {
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
  };
in {
  imports = [
    userConfig
  ];
}
