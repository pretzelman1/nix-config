{
  pkgs,
  inputs,
  config,
  lib,
  configVars,
  configLib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  pubKeys = lib.filesystem.listFilesRecursive ./keys;

  # Base user configuration that's common across all systems
  baseUserConfig = {
    users.users.${configVars.username} = {
      home = configLib.getHomeDirectory configVars.username;
      openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
      shell = pkgs.zsh;
    };

    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      just
      rsync
      git
    ];
  };

  # Linux-specific user configuration
  linuxUserConfig = {
    users = {
      mutableUsers = false;
      users.${configVars.username} = {
        isNormalUser = true;
        password = "nixos";
        extraGroups =
          ["wheel"]
          ++ ifTheyExist [
            "audio"
            "video"
            "docker"
            "git"
            "networkmanager"
          ];
      };
    };
  };

  # Non-minimal environment configurations
  fullEnvConfig = lib.optionalAttrs (!configVars.isMinimal) {
    users.users.${configVars.username}.packages = [pkgs.home-manager];
    home-manager.users.${configVars.username} = import (
      configLib.relativeToHome "${configVars.username}/${config.networking.hostName}.nix"
    );
  };
in {
  config = lib.mkMerge [
    baseUserConfig
    # (lib.optionalAttrs pkgs.stdenv.isLinux linuxUserConfig)
    fullEnvConfig
  ];
}
