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
  # sopsHashedPasswordFile =
  #   lib.optionalString (lib.hasAttr "sops-nix" inputs)
  #     config.sops.secrets."${configVars.username}/password".path;
  pubKeys = lib.filesystem.listFilesRecursive ./keys;

  # these are values we don't want to set if the environment is minimal. E.g. ISO or nixos-installer
  # isMinimal is true in the nixos-installer/flake.nix
  fullUserConfig = lib.optionalAttrs (!configVars.isMinimal) {
    users.users.${configVars.username} = {
      # hashedPasswordFile = sopsHashedPasswordFile;
      packages = [pkgs.home-manager];
    };

    # Import this user's personal/home configurations
    home-manager.users.${configVars.username} = import (
      configLib.relativeToHome "${configVars.username}/${config.networking.hostName}.nix"
    );
  };
in {
  config =
    lib.recursiveUpdate fullUserConfig
    # this is the second argument to recursiveUpdate
    {
      users.users.${configVars.username} =
        {
          home = configLib.getHomeDirectory configVars.username;

          # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
          openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);

          shell = pkgs.zsh; # default shell
        } // (lib.optionalAttrs (configLib.isLinux) {
          isNormalUser = true;
          password = "nixos"; # Overridden if sops is working

          extraGroups =
            ["wheel"]
            ++ ifTheyExist [
              "audio"
              "video" 
              "docker"
              "git"
              "networkmanager"
            ];
        });

      # No matter what environment we are in we want these tools for root, and the user(s)
      programs = {
        zsh.enable = true;
      };
      environment.systemPackages = with pkgs; [
        just
        rsync
        git
      ];
    }
    // (lib.optionalAttrs (configLib.isLinux) {
      users.mutableUsers = false; # Only allow declarative credentials; Required for sops
      # create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isminimal)
      # systemd.tmpfiles.rules =
      #   let
      #     user = config.users.users.${configVars.username}.name;
      #     group = config.users.users.${configVars.username}.group;
      #   in
      #   [ "d /home/${configVars.username}/.ssh/sockets 0750 ${user} ${group} -" ];
    });
}
