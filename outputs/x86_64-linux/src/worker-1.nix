{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `configLib.nixosSystem`, `configLib.colmenaSystem`, etc.
  inputs,
  lib,
  configLib,
  configVars,
  system,
  specialArgs,
  ...
} @ args: let
  name = "worker-1";
  ssh-user = "add";
  tags = [name];

  nixosSystemAttrs = configLib.nixosSystem (args
    // {
      inherit name;
    });
  inherit (nixosSystemAttrs) nixosSystem modules system;
in {
  # NixOS's configuration
  nixosConfigurations.${name} = nixosSystem;

  colmena.${name} = {
    deployment =
      {
        targetHost = configVars.networking.hostsAddr.${name}.ipv4;
        targetPort = 22;
        targetUser = ssh-user;
        buildOnTarget = true;
      }
      // {inherit tags;};

    imports = modules;
  };
}
