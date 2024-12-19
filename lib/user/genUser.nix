{
  user,
  commonConfig ? {},
  linuxConfig ? {},
  darwinConfig ? {},
  homeManagerConfig ? {},
  pubKeys ? [],
}: {
  pkgs,
  inputs,
  config,
  lib,
  configVars,
  configLib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # Base user configuration common across all systems
  baseUserConfig = lib.recursiveUpdate commonConfig {
    users.users.${user} = {
      home = lib.mkIf (user != "root") (configLib.getHomeDirectory user);
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = pubKeys;
    };
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      home-manager
    ];
  };

  # Linux-specific user configuration
  linuxUserConfig = lib.recursiveUpdate linuxConfig {
    users.users.${user} = {
      isNormalUser = lib.mkIf (user != "root") true;
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

  # Darwin-specific user configuration
  darwinUserConfig = lib.recursiveUpdate darwinConfig {
    users.users.${user} = {
      name = user;
      home = configLib.getHomeDirectory user;
    };
  };

  # Home Manager configuration
  homeManagerUserConfig = lib.recursiveUpdate homeManagerConfig {
    home-manager.users.${user} = let
      hmFile = configLib.relativeToHome "${user}/${config.networking.hostName}.nix";
    in
      lib.optionalAttrs (builtins.pathExists hmFile) {
        imports = [hmFile];
      };
  };
in {
  imports = [
    # Convert each configuration to a module
    baseUserConfig
    (lib.mkIf pkgs.stdenv.isLinux linuxUserConfig)
    (lib.mkIf pkgs.stdenv.isDarwin darwinUserConfig)
    homeManagerUserConfig
  ];
}
