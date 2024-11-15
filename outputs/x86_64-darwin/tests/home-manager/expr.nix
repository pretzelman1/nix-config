{
  configVars,
  lib,
  outputs,
}: let
  username = configVars.username;
  hosts = [
    "harmonica"
  ];
in
  lib.genAttrs
  hosts
  (
    name: outputs.darwinConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
  )
