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
    user = configVars.username;
    commonConfig = {
      environment.systemPackages = with pkgs; [
        just
        rsync
        git
      ];
    };
    linuxConfig = {
      users.users.${configVars.username} = {
        password = "nixos";
      };
    };
    pubKeys = lib.lists.forEach (lib.filesystem.listFilesRecursive ./keys) (key: builtins.readFile key);
  };
in {
  imports = [
    userConfig
  ];
}
