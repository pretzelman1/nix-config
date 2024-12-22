{
  pkgs,
  inputs,
  config,
  nix-secrets,
  lib,
  ...
}: let
  userConfig = lib.custom.genUser {
    user = config.hostSpec.username;
    commonConfig = {
      environment.systemPackages = with pkgs; [
        just
        rsync
        git
      ];
    };
    linuxConfig = {
      users.users.${config.hostSpec.username} = {
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
