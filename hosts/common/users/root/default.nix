{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  userConfig = lib.custom.genUser {
    user = "root";
    linuxConfig = {
      users.users.root = {
        hashedPasswordFile = config.users.users.${config.hostSpec.username}.hashedPasswordFile;
        password = lib.mkForce config.users.users.${config.hostSpec.username}.password;
      };
    };
    pubKeys = config.users.users.${config.hostSpec.username}.openssh.authorizedKeys.keys;
    homeManagerConfig = {
      home-manager.users.root = {
        home.stateVersion = config.hostSpec.system.stateVersion; # Avoid error
        imports = lib.flatten [
          (
            map lib.custom.relativeToHome [
              "${config.hostSpec.username}/common/core/cli/themes/oh-my-posh"
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
