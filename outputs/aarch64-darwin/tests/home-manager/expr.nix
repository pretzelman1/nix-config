{
  configVars,
  lib,
  outputs,
}: let
  username = configVars.username;
  hosts = [
    "fern"
  ];
in
  lib.genAttrs
  hosts
  (
    name: outputs.darwinConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
  )
